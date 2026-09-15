import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/client_report_row_model.dart';
import '../models/period_summary_model.dart';
import '../models/product_report_row_model.dart';
import '../models/report_suggestion_model.dart';
import '../models/sale_detail_line_model.dart';
import '../models/seller_report_row_model.dart';

class ReportsRemoteException implements Exception {
  final String? code;
  final String message;

  const ReportsRemoteException({this.code, this.message = ''});
}

abstract class ReportsRemoteDataSource {
  Future<PeriodSummaryModel> getPeriodSummary({
    required DateTime start,
    required DateTime end,
  });

  Future<List<ClientReportRowModel>> getReportByClient({
    required DateTime start,
    required DateTime end,
    int? limit,
  });

  Future<List<SellerReportRowModel>> getReportBySeller({
    required DateTime start,
    required DateTime end,
    int? limit,
  });

  Future<List<ProductReportRowModel>> getReportByProduct({
    required DateTime start,
    required DateTime end,
  });

  Future<List<ReportSuggestionModel>> searchClients(String query);

  Future<List<ReportSuggestionModel>> searchSellers(String query);

  Future<({List<SaleDetailLineModel> items, int totalCount})> getSaleDetails({
    required DateTime start,
    required DateTime end,
    String? clientId,
    String? sellerId,
    String search,
    String orderColumn,
    bool ascending,
    required int page,
    int pageSize,
  });
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final supabase.SupabaseClient client;

  const ReportsRemoteDataSourceImpl(this.client);

  @override
  Future<PeriodSummaryModel> getPeriodSummary({
    required DateTime start,
    required DateTime end,
  }) {
    return _guard(() async {
      final rows = await client.rpc(
        'period_summary',
        params: {'start_date': _dateParam(start), 'end_date': _dateParam(end)},
      );

      final list = rows as List;
      if (list.isEmpty) {
        return const PeriodSummaryModel(nSales: 0, totalSold: 0, avgTicket: 0);
      }

      return PeriodSummaryModel.fromJson(
        (list.first as Map).cast<String, dynamic>(),
      );
    });
  }

  @override
  Future<List<ClientReportRowModel>> getReportByClient({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) {
    return _guard(() async {
      final query = client.rpc(
        'report_by_client',
        params: {'start_date': _dateParam(start), 'end_date': _dateParam(end)},
      );
      final rows = limit == null ? await query : await query.limit(limit);
      return [
        for (final row in rows as List)
          ClientReportRowModel.fromJson((row as Map).cast<String, dynamic>()),
      ];
    });
  }

  @override
  Future<List<SellerReportRowModel>> getReportBySeller({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) {
    return _guard(() async {
      final query = client.rpc(
        'report_by_seller',
        params: {'start_date': _dateParam(start), 'end_date': _dateParam(end)},
      );
      final rows = limit == null ? await query : await query.limit(limit);
      return [
        for (final row in rows as List)
          SellerReportRowModel.fromJson((row as Map).cast<String, dynamic>()),
      ];
    });
  }

  @override
  Future<List<ProductReportRowModel>> getReportByProduct({
    required DateTime start,
    required DateTime end,
  }) {
    return _guard(() async {
      final rows = await client.rpc(
        'report_by_product',
        params: {'start_date': _dateParam(start), 'end_date': _dateParam(end)},
      );

      return [
        for (final row in rows as List)
          ProductReportRowModel.fromJson((row as Map).cast<String, dynamic>()),
      ];
    });
  }

  @override
  Future<List<ReportSuggestionModel>> searchClients(String query) {
    return _guard(() async {
      final term = _sanitizeSearchTerm(query);
      final rows = await client
          .from('clients')
          .select('id, name')
          .ilike('name', '%$term%')
          .order('name')
          .limit(6);

      return [for (final row in rows) ReportSuggestionModel.fromJson(row)];
    });
  }

  @override
  Future<List<ReportSuggestionModel>> searchSellers(String query) {
    return _guard(() async {
      final term = _sanitizeSearchTerm(query);
      final rows = await client
          .from('profiles')
          .select('id, name')
          .eq('role', 'seller')
          .ilike('name', '%$term%')
          .order('name')
          .limit(6);

      return [for (final row in rows) ReportSuggestionModel.fromJson(row)];
    });
  }

  @override
  Future<({List<SaleDetailLineModel> items, int totalCount})> getSaleDetails({
    required DateTime start,
    required DateTime end,
    String? clientId,
    String? sellerId,
    String search = '',
    String orderColumn = 'sale_date',
    bool ascending = false,
    required int page,
    int pageSize = 8,
  }) {
    return _guard(() async {
      var query = client
          .from('v_sales_details')
          .select('*')
          .gte('sale_date', _startOfDay(start).toIso8601String())
          .lte('sale_date', _endOfDay(end).toIso8601String());

      if (clientId != null) query = query.eq('client_id', clientId);
      if (sellerId != null) query = query.eq('seller_id', sellerId);

      final term = _sanitizeSearchTerm(search);
      if (term.isNotEmpty) {
        query = query.or('number.ilike.%$term%,product_name.ilike.%$term%');
      }

      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response = await query
          .order(orderColumn, ascending: ascending)
          .range(from, to)
          .count(supabase.CountOption.exact);

      final items = [
        for (final row in response.data) SaleDetailLineModel.fromJson(row),
      ];

      return (items: items, totalCount: response.count);
    });
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on supabase.PostgrestException catch (e) {
      throw ReportsRemoteException(code: e.code, message: e.message);
    } catch (e) {
      throw ReportsRemoteException(message: '$e');
    }
  }

  String _sanitizeSearchTerm(String query) {
    return query.trim().replaceAll(RegExp(r'[,%_()*"\\]'), '');
  }

  String _dateParam(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);
}

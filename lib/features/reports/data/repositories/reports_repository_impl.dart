import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/client_report_row.dart';
import '../../domain/entities/period_summary.dart';
import '../../domain/entities/product_report_row.dart';
import '../../domain/entities/report_suggestion.dart';
import '../../domain/entities/sale_details_page.dart';
import '../../domain/entities/seller_report_row.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  const ReportsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PeriodSummary>> getPeriodSummary({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final summary = await remoteDataSource.getPeriodSummary(
        start: start,
        end: end,
      );
      return Right(summary);
    } on ReportsRemoteException catch (e) {
      return Left(_mapRemoteError(e, 'No se pudieron cargar los reportes.'));
    }
  }

  @override
  Future<Either<Failure, List<ClientReportRow>>> getReportByClient({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    try {
      final rows = await remoteDataSource.getReportByClient(
        start: start,
        end: end,
        limit: limit,
      );
      return Right(rows);
    } on ReportsRemoteException catch (e) {
      return Left(_mapRemoteError(e, 'No se pudieron cargar los reportes.'));
    }
  }

  @override
  Future<Either<Failure, List<SellerReportRow>>> getReportBySeller({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    try {
      final rows = await remoteDataSource.getReportBySeller(
        start: start,
        end: end,
        limit: limit,
      );
      return Right(rows);
    } on ReportsRemoteException catch (e) {
      return Left(_mapRemoteError(e, 'No se pudieron cargar los reportes.'));
    }
  }

  @override
  Future<Either<Failure, List<ProductReportRow>>> getReportByProduct({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final rows = await remoteDataSource.getReportByProduct(
        start: start,
        end: end,
      );
      return Right(rows);
    } on ReportsRemoteException catch (e) {
      return Left(_mapRemoteError(e, 'No se pudieron cargar los reportes.'));
    }
  }

  @override
  Future<Either<Failure, List<ReportSuggestion>>> searchClients(
    String query,
  ) async {
    try {
      final rows = await remoteDataSource.searchClients(query);
      return Right(rows);
    } on ReportsRemoteException catch (e) {
      return Left(_mapRemoteError(e, 'No se pudo completar la búsqueda.'));
    }
  }

  @override
  Future<Either<Failure, List<ReportSuggestion>>> searchSellers(
    String query,
  ) async {
    try {
      final rows = await remoteDataSource.searchSellers(query);
      return Right(rows);
    } on ReportsRemoteException catch (e) {
      return Left(_mapRemoteError(e, 'No se pudo completar la búsqueda.'));
    }
  }

  @override
  Future<Either<Failure, SaleDetailsPage>> getSaleDetails({
    required DateTime start,
    required DateTime end,
    String? clientId,
    String? sellerId,
    String search = '',
    String orderColumn = 'sale_date',
    bool ascending = false,
    required int page,
    int pageSize = 8,
  }) async {
    try {
      final result = await remoteDataSource.getSaleDetails(
        start: start,
        end: end,
        clientId: clientId,
        sellerId: sellerId,
        search: search,
        orderColumn: orderColumn,
        ascending: ascending,
        page: page,
        pageSize: pageSize,
      );
      return Right(
        SaleDetailsPage(items: result.items, totalCount: result.totalCount),
      );
    } on ReportsRemoteException catch (e) {
      return Left(_mapRemoteError(e, 'No se pudieron cargar las ventas.'));
    }
  }

  Failure _mapRemoteError(ReportsRemoteException e, String fallbackMessage) {
    return switch (e.code) {
      '42501' => UnauthorizedFailure(
        message: 'No tienes permisos para ver los reportes.',
        code: e.code,
      ),
      _ => UnexpectedFailure(
        message: e.message.isEmpty ? fallbackMessage : e.message,
        code: e.code,
      ),
    };
  }
}

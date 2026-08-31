import 'package:arenero/features/reports/domain/entities/client_report_row.dart';
import 'package:arenero/features/reports/domain/entities/period_summary.dart';
import 'package:arenero/features/reports/domain/entities/product_report_row.dart';
import 'package:arenero/features/reports/domain/entities/report_suggestion.dart';
import 'package:arenero/features/reports/domain/entities/sale_detail_line.dart';
import 'package:arenero/features/reports/domain/entities/sale_details_page.dart';
import 'package:arenero/features/reports/domain/entities/seller_report_row.dart';

PeriodSummary buildPeriodSummary({
  int nSales = 4,
  double totalSold = 1000,
  double avgTicket = 250,
}) {
  return PeriodSummary(
    nSales: nSales,
    totalSold: totalSold,
    avgTicket: avgTicket,
  );
}

ClientReportRow buildClientReportRow({
  String clientId = 'client-1',
  String clientName = 'Juan Pérez',
  int nSales = 2,
  double total = 600,
}) {
  return ClientReportRow(
    clientId: clientId,
    clientName: clientName,
    nSales: nSales,
    total: total,
  );
}

SellerReportRow buildSellerReportRow({
  String sellerId = 'seller-1',
  String sellerName = 'Ana Vendedora',
  int nSales = 3,
  double totalSold = 900,
}) {
  return SellerReportRow(
    sellerId: sellerId,
    sellerName: sellerName,
    nSales: nSales,
    totalSold: totalSold,
  );
}

ProductReportRow buildProductReportRow({
  String productUnitId = 'product-unit-1',
  String productName = 'Arena fina',
  String unit = 'm3',
  double qtySold = 10,
  double totalAmount = 500,
}) {
  return ProductReportRow(
    productUnitId: productUnitId,
    productName: productName,
    unit: unit,
    qtySold: qtySold,
    totalAmount: totalAmount,
  );
}

ReportSuggestion buildReportSuggestion({
  String id = 'client-1',
  String name = 'Juan Pérez',
}) {
  return ReportSuggestion(id: id, name: name);
}

SaleDetailLine buildSaleDetailLine({
  String saleId = 'sale-1',
  String number = '12',
  DateTime? saleDate,
  String productName = 'Arena fina',
  String unit = 'm3',
  double quantity = 2,
  double subtotal = 40,
}) {
  return SaleDetailLine(
    saleId: saleId,
    number: number,
    saleDate: saleDate ?? DateTime(2026, 8, 10),
    productName: productName,
    unit: unit,
    quantity: quantity,
    subtotal: subtotal,
  );
}

SaleDetailsPage buildSaleDetailsPage({
  List<SaleDetailLine>? items,
  int totalCount = 1,
}) {
  return SaleDetailsPage(
    items: items ?? [buildSaleDetailLine()],
    totalCount: totalCount,
  );
}

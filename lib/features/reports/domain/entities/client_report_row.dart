class ClientReportRow {
  final String clientId;
  final String clientName;
  final int nSales;
  final double total;

  const ClientReportRow({
    required this.clientId,
    required this.clientName,
    required this.nSales,
    required this.total,
  });
}

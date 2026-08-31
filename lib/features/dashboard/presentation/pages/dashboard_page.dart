import 'package:flutter/material.dart';

import '../widgets/reports_client_tab.dart';
import '../widgets/reports_date_filter.dart';
import '../widgets/reports_products_tab.dart';
import '../widgets/reports_seller_tab.dart';
import '../widgets/reports_summary_tab.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ReportsDateFilter(),
            ),
            const SizedBox(height: 8),
            const TabBar(
              tabs: [
                Tab(text: 'Resumen'),
                Tab(text: 'Cliente'),
                Tab(text: 'Vendedor'),
                Tab(text: 'Producto'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  ReportsSummaryTab(),
                  ReportsClientTab(),
                  ReportsSellerTab(),
                  ReportsProductsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

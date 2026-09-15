import 'package:flutter/material.dart';

import '../../../../shared/widgets/page_header.dart';
import '../widgets/reports_client_tab.dart';
import '../widgets/reports_date_filter.dart';
import '../widgets/reports_products_tab.dart';
import '../widgets/reports_section_selector.dart';
import '../widgets/reports_seller_tab.dart';
import '../widgets/reports_summary_tab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ReportSection _section = ReportSection.summary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: PageHeader(
              title: 'Panel',
              description: 'Reportes y resumen general de ventas',
              icon: Icons.dashboard_rounded,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ReportsSectionSelector(
                    value: _section,
                    onChanged: (section) => setState(() => _section = section),
                  ),
                ),
                const SizedBox(width: 8),
                const ReportsDateFilter(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: IndexedStack(
              index: _section.index,
              children: [
                ReportsSummaryTab(
                  onShowSection: (section) =>
                      setState(() => _section = section),
                ),
                const ReportsClientTab(),
                const ReportsSellerTab(),
                const ReportsProductsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

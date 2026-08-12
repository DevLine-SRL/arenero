import 'package:flutter/material.dart';

import 'sale_section_card.dart';

class SaleDetailNotes extends StatelessWidget {
  final String notes;

  const SaleDetailNotes({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return SaleSectionCard(
      title: 'Notas',
      child: Text(notes, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

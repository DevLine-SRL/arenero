import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sale.dart';
import 'sales_history_mock_data.dart';

part 'sales_history_mock_provider.g.dart';

/// Fuente provisional de ventas del historial (datos mockeados).
///
/// Se reemplazará por el repositorio real cuando se conecte al backend.
@riverpod
List<Sale> salesHistoryMockData(Ref ref) => mockSalesData;

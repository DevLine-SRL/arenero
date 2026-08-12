import 'package:arenero/features/sales/data/models/sale_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _saleJson({Object? saleDeliveries}) {
  return {
    'id': 'sale-1',
    'number': 12,
    'client_id': 'client-1',
    'seller_id': 'seller-1',
    'sale_date': '2026-08-10T12:00:00Z',
    'delivery_mode': 'company_delivery',
    'payment_method': 'cash',
    'status': 'registered',
    'total': 20,
    'notes': null,
    'client': {
      'id': 'client-1',
      'name': 'Juan Pérez',
      'phone': null,
      'ci': '1234567',
      'nit': null,
      'active': true,
    },
    'seller': {'id': 'seller-1', 'name': 'Ana Vendedora', 'email': 'ana@x.com'},
    'sale_details': [
      {
        'id': 'detail-1',
        'sale_id': 'sale-1',
        'product_unit_id': 'product-unit-1',
        'quantity': 2,
        'unit_price': 10,
        'discount': 0,
        'product_unit': {
          'unit': 'm3',
          'product': {'name': 'Arena fina'},
        },
      },
    ],
    'sale_deliveries': saleDeliveries,
  };
}

const _deliveryRow = {
  'id': 'delivery-1',
  'sale_id': 'sale-1',
  'delivery_address': 'Av. Siempre Viva 742',
  'vehicle_plate': '1234-ABC',
  'delivery_date': '2026-08-11T09:00:00Z',
};

void main() {
  group('SaleModel.fromJson', () {
    // sale_deliveries.sale_id es UNIQUE, así que PostgREST devuelve el embed
    // como objeto. Antes solo se aceptaba un arreglo y la entrega se perdía
    // siempre.
    test('reads the delivery when the embed arrives as an object', () {
      final sale = SaleModel.fromJson(_saleJson(saleDeliveries: _deliveryRow));

      expect(sale.delivery, isNotNull);
      expect(sale.delivery!.deliveryAddress, 'Av. Siempre Viva 742');
      expect(sale.delivery!.vehiclePlate, '1234-ABC');
      expect(
        sale.delivery!.deliveryDate,
        DateTime.parse('2026-08-11T09:00:00Z'),
      );
    });

    test('reads the delivery when the embed arrives as a list', () {
      final sale = SaleModel.fromJson(
        _saleJson(saleDeliveries: [_deliveryRow]),
      );

      expect(sale.delivery, isNotNull);
      expect(sale.delivery!.deliveryAddress, 'Av. Siempre Viva 742');
    });

    test('leaves the delivery null when there is no row', () {
      expect(SaleModel.fromJson(_saleJson()).delivery, isNull);
      expect(
        SaleModel.fromJson(_saleJson(saleDeliveries: [])).delivery,
        isNull,
      );
    });

    test('reads the product name and the price the line was sold at', () {
      final sale = SaleModel.fromJson(_saleJson(saleDeliveries: _deliveryRow));

      expect(sale.details.single.productName, 'Arena fina');
      expect(sale.details.single.unitPrice, 10);
      expect(sale.number, 12);
      expect(sale.sellerName, 'Ana Vendedora');
    });

    test('falls back to the seller email when the profile has no name', () {
      final json = _saleJson(saleDeliveries: _deliveryRow);
      json['seller'] = {'id': 'seller-1', 'name': null, 'email': 'ana@x.com'};

      expect(SaleModel.fromJson(json).sellerName, 'ana@x.com');
    });
  });
}

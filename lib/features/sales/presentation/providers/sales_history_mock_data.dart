import '../../../clients/domain/entities/client.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_detail.dart';

/// Ventas falsas para maquetar la capa de presentación del historial.
///
/// Es un archivo provisional: se eliminará cuando el historial lea del
/// backend vía `GetSalesUseCase`.
final mockSalesData = <Sale>[
  Sale(
    id: '00000000-0000-0000-0000-000000000101',
    number: 1001,
    client: Client(
      id: '00000000-0000-0000-0000-0000000000a1',
      name: 'Constructora Santa Rita',
      ci: '1234567',
      active: true,
    ),
    sellerId: '00000000-0000-0000-0000-000000000001',
    saleDate: DateTime(2026, 8, 5, 10, 24),
    deliveryMode: SaleDeliveryMode.companyDelivery,
    paymentMethod: SalePaymentMethod.transfer,
    total: 4250.00,
    notes: 'Entrega en obra coordinada por teléfono.',
    details: [
      SaleDetail(
        productUnitId: 'p1',
        unit: ProductUnitOfMeasure.bag,
        quantity: 40,
        unitPrice: 98.50,
      ),
    ],
  ),
  Sale(
    number: 1002,
    client: Client(
      id: '00000000-0000-0000-0000-0000000000a2',
      name: 'Ferretería El Sol',
      ci: '8765432',
      phone: '591 71234567',
      active: true,
    ),
    sellerId: '00000000-0000-0000-0000-000000000001',
    saleDate: DateTime(2026, 8, 4, 17, 5),
    deliveryMode: SaleDeliveryMode.customerPickup,
    paymentMethod: SalePaymentMethod.qr,
    total: 1850.00,
    details: [
      SaleDetail(
        id: 'd1',
        productUnitId: 'p2',
        unit: ProductUnitOfMeasure.m3,
        quantity: 12.5,
        unitPrice: 148.00,
      ),
    ],
  ),
  Sale(
    number: 1003,
    client: Client(
      id: '00000000-0000-0000-0000-0000000000a3',
      name: 'Inmobiliaria Andina',
      ci: '9876543',
      active: true,
    ),
    sellerId: '00000000-0000-0000-0000-000000000002',
    saleDate: DateTime(2026, 8, 3, 9, 40),
    deliveryMode: SaleDeliveryMode.companyDelivery,
    paymentMethod: SalePaymentMethod.cash,
    total: 9200.00,
  ),
  Sale(
    number: 1004,
    client: Client(
      id: '00000000-0000-0000-0000-0000000000a4',
      name: 'Materiales Litoral',
      ci: '1112223',
      nit: '102345018',
      active: true,
    ),
    sellerId: '00000000-0000-0000-0000-000000000001',
    saleDate: DateTime(2026, 8, 2, 12, 40),
    deliveryMode: SaleDeliveryMode.companyDelivery,
    paymentMethod: SalePaymentMethod.transfer,
    total: 3120.75,
    notes: 'Factura a nombre de Constructora Litoral.',
  ),
];

import '../../domain/entities/sale_delivery.dart';

class SaleDeliveryModel extends SaleDelivery {
  const SaleDeliveryModel({
    super.deliveryAddress,
    super.vehiclePlate,
    super.deliveryDate,
  });

  factory SaleDeliveryModel.fromJson(Map<String, dynamic> json) {
    return SaleDeliveryModel(
      deliveryAddress: json['delivery_address'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      deliveryDate: json['delivery_date'] == null
          ? null
          : DateTime.parse(json['delivery_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
      if (deliveryDate != null)
        'delivery_date': deliveryDate!.toIso8601String(),
    };
  }
}

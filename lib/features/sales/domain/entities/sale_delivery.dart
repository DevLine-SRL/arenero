class SaleDelivery {
  final String? deliveryAddress;
  final String? vehiclePlate;
  final DateTime? deliveryDate;

  const SaleDelivery({
    this.deliveryAddress,
    this.vehiclePlate,
    this.deliveryDate,
  });

  SaleDelivery copyWith({
    String? deliveryAddress,
    bool clearDeliveryAddress = false,
    String? vehiclePlate,
    bool clearVehiclePlate = false,
    DateTime? deliveryDate,
    bool clearDeliveryDate = false,
  }) {
    return SaleDelivery(
      deliveryAddress: clearDeliveryAddress
          ? null
          : (deliveryAddress ?? this.deliveryAddress),
      vehiclePlate: clearVehiclePlate
          ? null
          : (vehiclePlate ?? this.vehiclePlate),
      deliveryDate: clearDeliveryDate
          ? null
          : (deliveryDate ?? this.deliveryDate),
    );
  }
}

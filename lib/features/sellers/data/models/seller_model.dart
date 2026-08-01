import '../../domain/entities/seller.dart';

class SellerModel extends Seller {
  const SellerModel({
    required super.id,
    required super.email,
    super.name,
    required super.active,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      active: json['active'] as bool,
    );
  }
}

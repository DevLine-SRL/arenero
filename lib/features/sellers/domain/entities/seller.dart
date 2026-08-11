import '../../../auth/domain/entities/user.dart';

class Seller extends User {
  const Seller({
    required super.id,
    required super.email,
    super.name,
    required super.active,
  }) : super(role: 'seller');

  Seller copyWith({String? id, String? email, String? name, bool? active}) {
    return Seller(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      active: active ?? this.active,
    );
  }
}

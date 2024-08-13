import 'pharmacy.dart';

class Product {
  String? title;
  int? quantity;
  double? price;
  bool isActive;
  Pharmacy? pharmacyInfo;
  String? pharmacy;
  int? createdAt;
  String? id;

  Product(
      {this.quantity,
      this.isActive = false,
      this.title,
      this.pharmacy,
      this.pharmacyInfo,
      this.id,
      this.createdAt,
      this.price});

  Product.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        quantity = json['quantity'],
        isActive = json['is_active'],
        pharmacy = json['pharmacy'],
        price = json['price'],
        id = json['id'],
        pharmacyInfo =
            Pharmacy?.fromJson(json['pharmacy_info'] as Map<String, dynamic>),
        createdAt = json['created_at'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'quantity': quantity,
        'is_active': isActive,
        'pharmacy': pharmacy,
        'id': id,
        'pharmacy_info': pharmacyInfo,
        'created_at': createdAt,
      };
}

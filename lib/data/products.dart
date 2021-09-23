import 'package:dbs/data/pharmacy.dart';

class Product {
  String? title;
  int? quantity;
  double? price;
  bool is_active;
  Pharmacy? pharmacy_info;
  String? pharmacy;
  int? created_at;
  String? id;

  Product(
      {this.quantity,
      this.is_active = false,
      this.title,
      this.pharmacy,
      this.pharmacy_info,
      this.id,
      this.created_at,
      this.price});

  Product.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        quantity = json['quantity'],
        is_active = json['is_active'],
        pharmacy = json['pharmacy'],
        price = json['price'],
        id = json['id'],
        pharmacy_info =
            Pharmacy?.fromJson(json['pharmacy_info'] as Map<String, dynamic>),
        created_at = json['created_at'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'quantity': quantity,
        'is_active': is_active,
        'pharmacy': pharmacy,
        'id': id,
        'pharmacy_info': pharmacy_info,
        'created_at': created_at,
      };
}

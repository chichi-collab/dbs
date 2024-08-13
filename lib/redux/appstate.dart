import 'package:geolocator/geolocator.dart';

import '../data/products.dart';
import '../data/user.dart';

class AppState {
  final UserModel? user;
  final Position? userLocation;
  final List<Product> products;

  AppState({this.user, this.userLocation, this.products = const []});
}

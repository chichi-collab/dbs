import 'package:dbs/data/products.dart';
import 'package:dbs/data/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppState {
  final UserModel? user;
  final Position? userLocation;
  final List<Product> products;

  AppState({this.user, this.userLocation, this.products = const []});
}

import 'package:dbs/data/products.dart';
import 'package:dbs/data/user.dart';
import 'package:geolocator/geolocator.dart';

class GetUserAction {
  final String? uid;

  GetUserAction({this.uid});
}

class GetUserActionSuccess {
  final UserModel? user;

  GetUserActionSuccess({this.user});
}

class GetUserLocation {
  final bool cancel;

  GetUserLocation({this.cancel = false});
}

class GetUserLocationSuccess {
  final Position? userLocation;

  GetUserLocationSuccess({this.userLocation});
}

class GetProductActionSuccess {
  final List<Product> products;

  GetProductActionSuccess({this.products = const []});
}

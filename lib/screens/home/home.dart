import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:dbs/customisedwidgets/buttons/primarybutton.dart';
import 'package:dbs/customisedwidgets/buttons/secondarybutton.dart';
import 'package:dbs/customisedwidgets/textinputs/custominput.dart';
import 'package:dbs/customisedwidgets/texts/black.dart';
import 'package:dbs/data/products.dart';
import 'package:dbs/redux/actions/useractions.dart';
import 'package:dbs/redux/appstate.dart';
import 'package:dbs/screens/home/order.dart';
import 'package:dbs/screens/home/search.dart';
import 'package:dbs/screens/login/login.dart';
import 'package:dbs/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:redux/redux.dart';
import 'package:google_maps_webservice/distance.dart' as distanceMatrix;
import '../../main.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleMapController? _controller;
  TextEditingController searchController = TextEditingController();
  TextInputError? error;
  CameraPosition _currentPostion = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 5.4746,
  );
  CameraPosition? currentPostion;

  bool locationServices = false;
  bool signoutIndicator = false;
  CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 20.151926040649414);
  Location location = new Location();
  late StreamSubscription streamLocation;

  Future _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      alert(
          yesString: 'Enable GPS services',
          yesPressed: () async {
            bool _resp = await location.requestService();
            setState(() {
              locationServices = _resp;
            });
          },
          message: 'Where are you?',
          info:
              "Turn on your device's location so we can pick up your items at the right spot and also find vehicles around you");
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        alert(
            yesString: 'Allow Permissions',
            yesPressed: () async {
              permission = await Geolocator.requestPermission();
            },
            message: 'Where are you?',
            info:
                "Grant this app permission to access your device's location so we can pick up your items at the right spot and also find vehicles around you");
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      alert(
          yesString: 'SETTINGS',
          yesPressed: () async {
            await Geolocator.openAppSettings();
          },
          message: 'Location permissions are permanently denied',
          info:
              'Open Settings to allow permissions. This is required to allow the app to show you how far away you are from products and shops');
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position userposition = await Geolocator.getCurrentPosition();
    StreamSubscription streamSubscription =
        Geolocator.getPositionStream(distanceFilter: 10)
            .listen((Position position) {
      if (position != null) {
        //   UserModel? user = getIt.get<Store<AppState>>().state.user;
        //   db
        //       .collection('users')
        //       .doc(user!.id)
        //       .update({'location': position.toJson()}).then((value) {});
        getIt
            .get<Store<AppState>>()
            .dispatch(GetUserLocationSuccess(userLocation: position));
        //   _controller?.moveCamera(CameraUpdate.newLatLngZoom(
        //       LatLng(position.latitude, position.longitude), 19));
        // }
      }
    });

    // log(userposition.longitude.toString(), name: 'latitude');
    setState(() {
      streamLocation = streamSubscription;
      _currentPostion = CameraPosition(
          target: LatLng(userposition.latitude, userposition.longitude));
      currentPostion = CameraPosition(
          target: LatLng(userposition.latitude, userposition.longitude));
    });
    if (_controller != null) {
      _controller?.moveCamera(CameraUpdate.newLatLngZoom(
          LatLng(userposition.latitude, userposition.longitude), 17));
    }
  }

  Product? selectedProduct;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (streamLocation != null) {
      streamLocation.cancel();
    }
    _customInfoWindowController.dispose();
    super.dispose();
  }

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  Set<Marker>? _markers;

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      builder: (context, AppState state) {
        return Scaffold(
            body: SafeArea(
          child: Stack(
            children: [
              GoogleMap(
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                // scrollGesturesEnabled: show != "confirm",
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                onCameraMove: (position) {
                  _customInfoWindowController.onCameraMove!();
                },
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) async {
                  _customInfoWindowController.googleMapController = controller;
                  // _controller.complete(controller);
                  setState(() {
                    _controller = controller;
                  });
                  if (currentPostion != null) {
                    _controller?.moveCamera(
                        CameraUpdate.newLatLngZoom(currentPostion!.target, 17));
                  }
                },
                markers: _markers != null ? _markers! : {},
                onCameraIdle: () {},
                initialCameraPosition: _currentPostion,
                // onMapCreated: (GoogleMapController controller) {
                //   // _controller.complete(controller);
                //   setState(() {
                //     _controller = controller;
                //   });
                //   if (currentPostion != null) {
                //     _controller?.moveCamera(
                //         CameraUpdate.newLatLngZoom(currentPostion!.target, 17));
                //   }
                // },
              ),
              CustomInfoWindow(
                controller: _customInfoWindowController,
                // height: 75,
                width: 180,
                offset: 45,
              ),
              Positioned(
                top: 20,
                child: Hero(
                    tag: 'search',
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15)),
                            backgroundColor:
                                MaterialStateProperty.all(DefaultColors.white),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        onPressed: () async {
                          if (_markers != null) {
                            _customInfoWindowController.hideInfoWindow!();
                          }
                          Product? search = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                            return Search(tag: 'search');
                          }));

                          setState(() {
                            selectedProduct = search;
                            if (search != null) {
                              double distanceInMeters =
                                  Geolocator.distanceBetween(
                                      state.userLocation!.latitude,
                                      state.userLocation!.longitude,
                                      search.pharmacy_info!.location!['coords']
                                          ['lat'],
                                      search.pharmacy_info!.location!['coords']
                                          ['lng']);
                              _markers = <Marker>{
                                Marker(
                                    markerId: MarkerId(search.id.toString()),
                                    onTap: () {
                                      _customInfoWindowController
                                              .addInfoWindow!(
                                          Column(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: DefaultColors.white,
                                                    border: Border.all(
                                                        color:
                                                            DefaultColors.ash),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          color: DefaultColors
                                                              .green,
                                                          child: Text(
                                                            distanceValue!.text,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 8.0,
                                                        ),
                                                        Text(
                                                            search.title
                                                                .toString(),
                                                            style: TextStyle(
                                                                color:
                                                                    DefaultColors
                                                                        .ash))
                                                      ],
                                                    ),
                                                  ),
                                                  width: double.infinity,
                                                  // height: double.infinity,
                                                ),
                                              ),
                                              // Triangle.isosceles(
                                              //   edge: Edge.BOTTOM,
                                              //   child: Container(
                                              //     color: Colors.blue,
                                              //     width: 20.0,
                                              //     height: 10.0,
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                          LatLng(
                                              search.pharmacy_info!
                                                  .location!['coords']['lat'],
                                              search.pharmacy_info!
                                                  .location!['coords']['lng']));
                                    },
                                    // infoWindow: InfoWindow(
                                    //
                                    //     title: selectedProduct!.title.toString(),
                                    //     snippet: selectedProduct!.pharmacy_info!.title
                                    //         .toString()),
                                    // // icon: _destinationIcon!,
                                    position: LatLng(
                                        selectedProduct!.pharmacy_info!
                                            .location!['coords']['lat'],
                                        selectedProduct!.pharmacy_info!
                                            .location!['coords']['lng']))
                              };
                            } else {
                              setState(() {
                                polylines = {};
                                _markers = {};
                              });
                            }
                          });

                          if (search != null) {
                            _getDistance(
                                origin: LatLng(state.userLocation!.latitude,
                                    state.userLocation!.longitude),
                                dest: LatLng(
                                    search.pharmacy_info!.location!['coords']
                                        ['lat'],
                                    search.pharmacy_info!.location!['coords']
                                        ['lng']));
                            _getPolyline(
                                origin: LatLng(state.userLocation!.latitude,
                                    state.userLocation!.longitude),
                                dest: LatLng(
                                    search.pharmacy_info!.location!['coords']
                                        ['lat'],
                                    search.pharmacy_info!.location!['coords']
                                        ['lng']));
                          }

                          // _controller?.moveCamera(CameraUpdate.newLatLngBounds(
                          //     selectedProduct!.pharmacy_info!.location!['coords']['lat'] <=
                          //             state.userLocation!.latitude
                          //         ? LatLngBounds(
                          //             southwest: LatLng(
                          //                 selectedProduct!
                          //                         .pharmacy_info!
                          //                         .location!['coords']
                          //                     ['lat'],
                          //                 selectedProduct!
                          //                         .pharmacy_info!
                          //                         .location!['coords']
                          //                     ['lng']),
                          //             northeast: LatLng(
                          //                 state.userLocation!.latitude,
                          //                 state.userLocation!.longitude))
                          //         : LatLngBounds(northeast: LatLng(state.userLocation!.latitude, state.userLocation!.longitude), southwest: LatLng(selectedProduct!.pharmacy_info!.location!['coords']['lat'], selectedProduct!.pharmacy_info!.location!['coords']['lng'])),
                          //     10));
                          log(search.toString(), name: 'search result');
                        },
                        child: Row(
                          children: [
                            Text(
                              selectedProduct != null
                                  ? selectedProduct!.title.toString()
                                  : 'Search drug...',
                              style: TextStyle(color: DefaultColors.ash),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
              Visibility(
                  visible: selectedProduct != null,
                  child: Positioned(
                      top: 80,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                                color: DefaultColors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: DefaultColors.shadowColorGrey,
                                      offset: Offset(0, 1),
                                      blurRadius: 2)
                                ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    BlackText(
                                        margin: EdgeInsets.zero,
                                        text: selectedProduct == null
                                            ? ""
                                            : selectedProduct!.pharmacy_info !=
                                                    null
                                                ? selectedProduct!
                                                    .pharmacy_info!.title
                                                    .toString()
                                                : ""),
                                    BlackText(
                                        text: "ETA: " +
                                            (durationValue == null
                                                ? ""
                                                : durationValue!.text))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Location: " +
                                        (selectedProduct == null
                                            ? ""
                                            : selectedProduct!.pharmacy_info!
                                                .location!['name']
                                                .toString())),
                                    BlackText(
                                        size: 14,
                                        text: 'Price: GHC ' +
                                            selectedProduct!.price.toString())
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  width: MediaQuery.of(context).size.width,
                                  child: SecondaryButton(
                                    onPressed: () async {
                                      Product? search = await Navigator.of(
                                              context)
                                          .push(MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return Order(
                                                    product: selectedProduct!);
                                              },
                                              fullscreenDialog: true));
                                    },
                                    text: 'Order',
                                    backgroundColor: DefaultColors.green,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          )))),
              Positioned(
                  bottom: 30,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                        color: DefaultColors.white,
                        boxShadow: [
                          BoxShadow(
                              color: DefaultColors.shadowColorGrey,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                        borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                        onPressed: signoutIndicator
                            ? null
                            : () async {
                                signOutDialog();
                              },
                        child: signoutIndicator
                            ? Container(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      DefaultColors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                children: [
                                  Icon(Icons.logout),
                                  BlackText(text: 'Sign out')
                                ],
                              )),
                  )),
              Visibility(
                visible: selectedProduct != null && bounds != null,
                child: Positioned(
                    bottom: 100,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                          color: DefaultColors.white,
                          boxShadow: [
                            BoxShadow(
                                color: DefaultColors.shadowColorGrey,
                                blurRadius: 10,
                                offset: Offset(0, 5))
                          ],
                          borderRadius: BorderRadius.circular(40)),
                      child: TextButton(
                          onPressed: () async {
                            _controller?.moveCamera(
                                CameraUpdate.newLatLngBounds(bounds!, 40));
                          },
                          child: Row(
                            children: [
                              Icon(Icons.map),
                            ],
                          )),
                    )),
              ),
              Positioned(
                  bottom: 30,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                        color: DefaultColors.white,
                        boxShadow: [
                          BoxShadow(
                              color: DefaultColors.shadowColorGrey,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                        borderRadius: BorderRadius.circular(40)),
                    child: TextButton(
                        onPressed: () async {
                          _controller?.moveCamera(CameraUpdate.newLatLngZoom(
                              LatLng(state.userLocation!.latitude,
                                  state.userLocation!.longitude),
                              17));
                        },
                        child: Row(
                          children: [
                            Icon(Icons.gps_fixed),
                          ],
                        )),
                  ))
            ],
          ),
        ));
      },
      converter: (Store<AppState> store) => store.state,
    );
  }

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  LatLngBounds? bounds;
  String googleAPiKey = "AIzaSyCSfLqHtXZmHww98tHHDPkd70yB-3FVTT4";
  distanceMatrix.Value? distanceValue;
  distanceMatrix.Value? durationValue;

  final distance = new distanceMatrix.GoogleDistanceMatrix(
    apiKey: "AIzaSyCSfLqHtXZmHww98tHHDPkd70yB-3FVTT4",
  );

  _getDistance({
    required LatLng origin,
    required LatLng dest,
  }) async {
    distanceMatrix.DistanceResponse response = await distance
        .distanceWithLocation([
      distanceMatrix.Location(lat: origin.latitude, lng: origin.longitude)
    ], [
      distanceMatrix.Location(lat: dest.latitude, lng: dest.longitude)
    ]);
    log(response.rows[0].elements[0].distance.text);

    distanceMatrix.Value distanceVal = response.rows[0].elements[0].distance;
    distanceMatrix.Value durationVal = response.rows[0].elements[0].duration;

    setState(() {
      distanceValue = distanceVal;
      durationValue = durationVal;
    });
  }

  _getPolyline({required LatLng origin, required LatLng dest}) async {
    // log('message before directions');
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${dest.latitude},${dest.longitude}&key=${googleAPiKey}');
    var response = await http.get(
      url,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);
    log(responseMap['routes'][0]['bounds']['northeast'].toString(),
        name: 'directions');
    setState(() {
      bounds = LatLngBounds(
          southwest: LatLng(
              responseMap['routes'][0]['bounds']['southwest']['lat'],
              responseMap['routes'][0]['bounds']['southwest']['lng']),
          northeast: LatLng(
              responseMap['routes'][0]['bounds']['northeast']['lat'],
              responseMap['routes'][0]['bounds']['northeast']['lng']));
    });
    _controller?.moveCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(
                responseMap['routes'][0]['bounds']['southwest']['lat'],
                responseMap['routes'][0]['bounds']['southwest']['lng']),
            northeast: LatLng(
                responseMap['routes'][0]['bounds']['northeast']['lat'],
                responseMap['routes'][0]['bounds']['northeast']['lng'])),
        40));
    // });
    // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    //   googleAPiKey,
    //   PointLatLng(origin.latitude, origin.longitude),
    //   PointLatLng(dest.latitude, dest.longitude),
    //   // travelMode: TravelMode.driving,
    //
    //   // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]
    // );
    // if (result.points.isNotEmpty) {
    List<PointLatLng> result = polylinePoints.decodePolyline(
        responseMap['routes'][0]['overview_polyline']['points']);
    List<LatLng> polylineCoordinatesInit = [];

    result.forEach((PointLatLng point) {
      polylineCoordinatesInit.add(LatLng(point.latitude, point.longitude));
    });
    setState(() {
      polylineCoordinates = polylineCoordinatesInit;
    });
    // } else {
    //   log(result.errorMessage.toString());
    // }
    _addPolyLine(polylineCoords: polylineCoordinatesInit);
  }

  _addPolyLine({required List<LatLng> polylineCoords}) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        width: 4, polylineId: id, color: Colors.red, points: polylineCoords);
    Map<PolylineId, Polyline> polylinesInit = {};

    polylinesInit[id] = polyline;
    setState(() {
      polylines = polylinesInit;
    });
  }

  Future<void> signOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Sign Out')],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: BlackText(
                    text: 'Do you want to sign out?',
                    weight: FontWeight.normal,
                    size: 14,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    PrimaryButton(
                      onPressed: () async {
                        setState(() {
                          signoutIndicator = true;
                        });
                        await FirebaseAuth.instance.signOut();
                        if ((await GoogleSignIn().isSignedIn())) {
                          await GoogleSignIn().disconnect();
                        }
                        setState(() {
                          signoutIndicator = false;
                        });
                        getIt
                            .get<Store<AppState>>()
                            .dispatch(GetUserActionSuccess(user: null));

                        // getIt
                        //     .get<Store<AppState>>()
                        //     .dispatch(HideNavBarAction(hidebar: true));

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                            (route) => false);
                      },
                      buttonText: 'Yes',
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> alert(
      {required String message,
      String info = '',
      required Function yesPressed,
      String yesString = 'YES'}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('ALERT')],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                BlackText(text: message),
                BlackText(
                  text: info,
                  weight: FontWeight.normal,
                  size: 14,
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: BlackText(
                text: 'CLOSE',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PrimaryButton(
              buttonText: yesString,
              onPressed: () {
                yesPressed();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
// Container(
// padding: EdgeInsets.symmetric(horizontal: 25),
// width: MediaQuery.of(context).size.width,
// child: TextField(
// controller: searchController,
// style: TextStyle(
// color: DefaultColors.ash, fontWeight: FontWeight.bold),
// cursorColor: DefaultColors.green,
// decoration: InputDecoration(
// suffixIcon: Icon(Icons.search),
// errorText: error != null
// ? error!.visible
// ? error!.message
//     : null
// : null,
// fillColor: DefaultColors.white,
// filled: true,
// hintText: "Search drug...",
// hintStyle: TextStyle(
// color: DefaultColors.ash,
// fontWeight: FontWeight.normal),
// focusedBorder: OutlineInputBorder(
// borderRadius: BorderRadius.circular(10),
// borderSide: BorderSide(
// style: BorderStyle.solid,
// color: DefaultColors.green,
// width: 2)),
// border: OutlineInputBorder(
// borderRadius: BorderRadius.circular(10),
// borderSide:
// BorderSide(color: DefaultColors.ash, width: 2)),
// enabledBorder: OutlineInputBorder(
// borderRadius: BorderRadius.circular(10),
// borderSide: BorderSide(
// style: BorderStyle.solid,
// color: DefaultColors.ash,
// width: 2)),
// disabledBorder: OutlineInputBorder(
// borderRadius: BorderRadius.circular(10),
// borderSide:
// BorderSide(color: DefaultColors.ash, width: 2))),
// ),
// ),

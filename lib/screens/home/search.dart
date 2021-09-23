import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dbs/constants/firestore.dart';
import 'package:dbs/customisedwidgets/textinputs/custominput.dart';
import 'package:dbs/customisedwidgets/texts/black.dart';
import 'package:dbs/data/products.dart';
import 'package:dbs/redux/appstate.dart';
import 'package:dbs/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:redux/redux.dart';

import '../../main.dart';

class Search extends StatefulWidget {
  final String tag;

  Search({required this.tag});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchTextEditingController = TextEditingController();
  List<Product> searchResults = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // searchTextEditingController.addListener(() {
    //
    // });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      builder: (context, AppState state) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: DefaultColors.yellow,
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: DefaultColors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: CustomInput(
                autofocus: true,
                onChanged: (String value) async {
                  log(value, name: 'Search value');
                  if (value.length > 0) {
                    setState(() {
                      loading = true;
                    });
                    List<Product> SearchListInit = [];
                    List<Product> results = state.products;

                    if (results.length > 0) {
                      results.forEach((element) {
                        if (element.title!
                            .toLowerCase()
                            .contains(value.toLowerCase().trim())) {
                          SearchListInit.add(element);
                        }
                      });
                    }
                    setState(() {
                      loading = false;
                      searchResults = SearchListInit;
                    });
                  }
                },
                height: 50,
                controller: searchTextEditingController,
                hint: 'Search',
              ),
            ),
            body: SafeArea(
              child: Hero(
                  tag: widget.tag,
                  child: Container(
                      // The blue background emphasizes that it's a new route.
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: loading
                          ? Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: DefaultColors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: DefaultColors.shadowColorGrey,
                                        offset: Offset(0, 10),
                                        blurRadius: 20)
                                  ]),
                              // width: 30,
                              // height: 30,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(DefaultColors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : searchResults.length == 0
                              ? Text(
                                  'No Product with the title: ${searchTextEditingController.text.trim()} found',
                                  style: TextStyle(color: Colors.red),
                                )
                              : ListView.builder(
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    Product product = searchResults[index];
                                    double distanceInMeters =
                                        Geolocator.distanceBetween(
                                            state.userLocation!.latitude,
                                            state.userLocation!.longitude,
                                            product.pharmacy_info!
                                                .location!['coords']['lat'],
                                            product.pharmacy_info!
                                                .location!['coords']['lng']);
                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: DefaultColors
                                                      .shadowColorGrey,
                                                  width: 1))),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.pop(
                                              context, searchResults[index]);
                                        },
                                        title: BlackText(
                                          margin: EdgeInsets.zero,
                                          text: product.title!,
                                        ),
                                        isThreeLine: true,
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Price: GHC " +
                                                product.price.toString()),
                                            Text(product.pharmacy_info!.title
                                                .toString()),
                                          ],
                                        ),
                                        trailing: Text(
                                          'about ' +
                                              (distanceInMeters / 1000)
                                                  .floor()
                                                  .toString() +
                                              ' km away',
                                          style: TextStyle(
                                              color: DefaultColors.ash),
                                        ),
                                      ),
                                    );
                                  },
                                ))),
            ));
      },
      converter: (Store<AppState> store) => store.state,
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

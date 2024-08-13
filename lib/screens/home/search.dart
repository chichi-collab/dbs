import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:redux/redux.dart';

import '../../customisedwidgets/texts/black.dart';
import '../../data/products.dart';
import '../../redux/appstate.dart';
import '../../theme/colors.dart';

class Search extends StatefulWidget {
  final String tag;

  const Search({super.key, required this.tag});

  @override
  State<Search> createState() => _SearchState();
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
                  icon: const Icon(
                    Icons.arrow_back,
                    color: DefaultColors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: TextField(
                autofocus: true,

                onChanged: (String value) async {
                  log(value, name: 'Search value');
                  if (value.isNotEmpty) {
                    setState(() {
                      loading = true;
                    });
                    List<Product> searchListInit = [];
                    List<Product> results = state.products;

                    if (results.isNotEmpty) {
                      for (var element in results) {
                        if (element.title!
                            .toLowerCase()
                            .contains(value.toLowerCase().trim())) {
                          searchListInit.add(element);
                        }
                      }
                    }
                    setState(() {
                      loading = false;
                      searchResults = searchListInit;
                    });
                  }
                },
                // height: 50,
                controller: searchTextEditingController,

                style: const TextStyle(
                    color: DefaultColors.ash, fontWeight: FontWeight.bold),
                cursorColor: DefaultColors.green,
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Search",
                    hintStyle: const TextStyle(
                        color: DefaultColors.ash,
                        fontWeight: FontWeight.normal),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(5)),
                    // border: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(10),
                    //     borderSide:
                    //         BorderSide(color: DefaultColors.ash, width: 2)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(5))),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: DefaultColors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: DefaultColors.shadowColorGrey,
                                        offset: Offset(0, 10),
                                        blurRadius: 20)
                                  ]),
                              // width: 30,
                              // height: 30,
                              child: const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(DefaultColors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : searchResults.isEmpty &&
                                  searchTextEditingController.text.isNotEmpty
                              ? SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LottieBuilder.asset(
                                      'lib/lottiefiles/notfound.json',
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.2,
                                    ),
                                    Text(
                                      'No Product with the title: ${searchTextEditingController.text.trim()} found',
                                      style: const TextStyle(
                                          color: Colors.red),
                                    )
                                  ],
                                ),
                              )
                              : ListView.builder(
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    Product product = searchResults[index];
                                    double distanceInMeters =
                                        Geolocator.distanceBetween(
                                            state.userLocation!.latitude,
                                            state.userLocation!.longitude,
                                            product.pharmacyInfo!
                                                .location!['coords']['lat'],
                                            product.pharmacyInfo!
                                                .location!['coords']['lng']);
                                    return Container(
                                      decoration: const BoxDecoration(
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
                                            Text("Price: GHC ${product.price}"),
                                            Text(product.pharmacyInfo!.title
                                                .toString()),
                                          ],
                                        ),
                                        trailing: Text(
                                          'about ${(distanceInMeters / 1000).floor()} km away',
                                          style: const TextStyle(
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

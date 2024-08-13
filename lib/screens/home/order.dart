import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../constants/firestore.dart';
import '../../customisedwidgets/buttons/primarybutton.dart';
import '../../customisedwidgets/buttons/secondarybutton.dart';
import '../../customisedwidgets/texts/black.dart';
import '../../data/products.dart';
import '../../redux/appstate.dart';
import '../../theme/colors.dart';

class Order extends StatefulWidget {
  const Order({super.key, required this.product});
  final Product product;

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  int quantity = 0;
  bool order = false;
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      builder: (context, AppState state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: DefaultColors.green,
            elevation: 0,
            title: Text(widget.product.pharmacyInfo!.title.toString()),
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                  child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: Container(
                      color: DefaultColors.green,
                    ),
                  ),
                  Positioned(
                      bottom: -25,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                  offset: Offset(0, 5),
                                  color: DefaultColors.shadowColorGrey,
                                  blurRadius: 10)
                            ]),
                        child: BlackText(
                          text: widget.product.title!.toString(),
                          size: 20,
                        ),
                      ))
                ],
              )),
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 70,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const BlackText(text: 'Quantity'),
                          Row(
                            children: [
                              SecondaryButton(
                                onPressed: () {
                                  if (quantity > 0) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                                backgroundColor: DefaultColors.shadowColorGrey,
                                text: '-',
                                color: Colors.black,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: BlackText(text: quantity.toString()),
                              ),
                              SecondaryButton(
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                                backgroundColor: DefaultColors.shadowColorGrey,
                                text: '+',
                                color: Colors.black,
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const BlackText(text: 'Price'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                      offset: Offset(0, 5),
                                      color: DefaultColors.shadowColorGrey,
                                      blurRadius: 10)
                                ]),
                            child: BlackText(
                              text: 'GHC ${widget.product.price}',
                              size: 20,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const BlackText(text: 'Total'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                      offset: Offset(0, 5),
                                      color: DefaultColors.shadowColorGrey,
                                      blurRadius: 10)
                                ]),
                            child: BlackText(
                              text:
                                  'GHC ${(widget.product.price! * quantity).toStringAsFixed(2)}',
                              size: 20,
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: PrimaryButton(
                          elevation: 0,
                          buttonText: 'Order',
                          indicator: order,
                          onPressed: quantity == 0
                              ? null
                              : order
                                  ? null
                                  : () {
                                      setState(() {
                                        order = true;
                                      });
                                      db.collection('orders').doc().set({
                                        "total":
                                            (widget.product.price! * quantity)
                                                .toStringAsFixed(2),
                                        "quantity": quantity,
                                        'created_at': DateTime.now(),
                                        'user': {
                                          "id": state.user!.id,
                                          "name": state.user!.name,
                                          'email': state.user!.email,
                                        },
                                        "product": {
                                          "id": widget.product.id,
                                          "price": widget.product.price,
                                          "pharmacy_info": widget
                                              .product.pharmacyInfo!
                                              .toJson(),
                                          "title": widget.product.title,
                                          "pharmacy": widget.product.pharmacy,
                                        }
                                      }).then((value) {
                                        setState(() {
                                          order = false;
                                        });
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Product ordered successfully',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                        Timer(const Duration(seconds: 4), () {
                                          Navigator.pop(context);
                                        });
                                      }).catchError((error) {
                                        setState(() {
                                          order = false;
                                        });
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                              'An error occurred, Try again..',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      });
                                    },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
      converter: (Store<AppState> store) => store.state,
    );
  }
}

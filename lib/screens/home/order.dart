import 'package:dbs/customisedwidgets/buttons/primarybutton.dart';
import 'package:dbs/customisedwidgets/buttons/secondarybutton.dart';
import 'package:dbs/customisedwidgets/texts/black.dart';
import 'package:dbs/data/pharmacy.dart';
import 'package:dbs/data/products.dart';
import 'package:dbs/theme/colors.dart';
import 'package:flutter/material.dart';

class Order extends StatefulWidget {
  const Order({Key? key, required this.product}) : super(key: key);
  final Product product;

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DefaultColors.green,
        elevation: 0,
        title: Text(widget.product.pharmacy_info!.title.toString()),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Stack(
            alignment: Alignment.bottomCenter,
            overflow: Overflow.visible,
            children: [
              Positioned.fill(
                child: Container(
                  color: DefaultColors.green,
                ),
              ),
              Positioned(
                  bottom: -25,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
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
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlackText(text: 'Quantity'),
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
                            margin: EdgeInsets.symmetric(horizontal: 10),
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
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlackText(text: 'Price'),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 5),
                                  color: DefaultColors.shadowColorGrey,
                                  blurRadius: 10)
                            ]),
                        child: BlackText(
                          text: 'GHC ' + widget.product.price.toString(),
                          size: 20,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlackText(text: 'Total'),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 5),
                                  color: DefaultColors.shadowColorGrey,
                                  blurRadius: 10)
                            ]),
                        child: BlackText(
                          text: 'GHC ' +
                              (widget.product.price! * quantity)
                                  .toStringAsFixed(2),
                          size: 20,
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    child: PrimaryButton(
                      elevation: 0,
                      buttonText: 'Order',
                      onPressed: quantity == 0 ? null : () {},
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
            ),
          )
        ],
      ),
    );
  }
}

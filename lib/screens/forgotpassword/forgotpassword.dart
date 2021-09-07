import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dbs/constants/auth.dart';
import 'package:dbs/customisedwidgets/buttons/primarybutton.dart';
import 'package:dbs/customisedwidgets/textinputs/custominput.dart';
import 'package:dbs/customisedwidgets/texts/black.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool indicator = false;
  bool sent = false;
  TextInputError? emailError;
  TextEditingController email = TextEditingController();

  void resetPassword({required String email}) {
    this.setState(() {
      indicator = true;
      emailError = null;
    });
    auth
        .sendPasswordResetEmail(email: email)
        .then((value) =>
    {
      this.setState(() {
        indicator = false;
        sent = true;
      })
    })
        .catchError((error) =>
    {
      this.setState(() {
        emailError =
            TextInputError(visible: true, message: error.toString());
        indicator = false;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.7,
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    margin: EdgeInsets.only(top: 15, bottom: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 15, bottom: 10),
                          child: BlackText(
                            text: 'Forgot Password?',
                            size: 20,
                          ),
                        ),
                        Positioned(
                          // top: -10,
                            right: 0,
                            child: Container(
                              child: IconButton(
                                  color: Colors.red,
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            ))
                      ],
                    )),
              ),
              Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      BlackText(
                          text: 'Enter your email to recover the password'),
                      Container(
                        child: Image.asset(
                            'lib/assets/lock_one.png'),
                      ),
                      CustomInput(
                        controller: email,
                        hint: 'Email',
                        error: emailError,
                      ),
                    ],
                  )),
              Expanded(
                  child: Container(
                    child: Row(children: [
                      Expanded(
                        child: PrimaryButton(
                          buttonText: 'Send Email',
                          onPressed: () {
                            if (email.text.contains('@') &&
                                email.text.contains('.') &&
                                email.text.length > 5) {
                              this.setState(() {
                                emailError = null;
                              });

                              resetPassword(
                                  email: email.text.toLowerCase().trim());
                            } else {
                              this.setState(() {
                                emailError = TextInputError(
                                    visible: !email.text.contains('@') ||
                                        !email.text.contains('.'),
                                    message: !email.text.contains('@')
                                        ? 'Email must contain @'
                                        : !email.text.contains('.')
                                        ? 'Email must contain .'
                                        : 'Email length not enough');
                              });
                            }

                            // this.setState(() {
                            //   indicator = !indicator;
                            // });
                          },
                        ),
                      )
                    ]),
                  ))
            ],
          )),
    ]);
  }
}

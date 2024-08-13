import 'package:flutter/material.dart';

import '../../constants/auth.dart';
import '../../customisedwidgets/buttons/primarybutton.dart';
import '../../customisedwidgets/textinputs/custominput.dart';
import '../../customisedwidgets/texts/black.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool indicator = false;
  bool sent = false;
  TextInputError? emailError;
  TextEditingController email = TextEditingController();

  void resetPassword({required String email}) {
    setState(() {
      indicator = true;
      emailError = null;
    });
    auth
        .sendPasswordResetEmail(email: email)
        .then((value) => {
              setState(() {
                indicator = false;
                sent = true;
              })
            })
        .catchError((error) => {
              setState(() {
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
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 15, bottom: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 15, bottom: 10),
                          child: const BlackText(
                            text: 'Forgot Password?',
                            size: 20,
                          ),
                        ),
                        Positioned(
                            // top: -10,
                            right: 0,
                            child: IconButton(
                                color: Colors.red,
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                }))
                      ],
                    )),
              ),
              Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      const BlackText(
                          text: 'Enter your email to recover the password'),
                      Image.asset('lib/assets/lock_one.png'),
                      CustomInput(
                        controller: email,
                        hint: 'Email',
                        error: emailError,
                      ),
                    ],
                  )),
              Expanded(
                  child: Row(children: [
                Expanded(
                  child: PrimaryButton(
                    buttonText: 'Send Email',
                    onPressed: () {
                      if (email.text.contains('@') &&
                          email.text.contains('.') &&
                          email.text.length > 5) {
                        setState(() {
                          emailError = null;
                        });

                        resetPassword(email: email.text.toLowerCase().trim());
                      } else {
                        setState(() {
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
              ]))
            ],
          )),
    ]);
  }
}

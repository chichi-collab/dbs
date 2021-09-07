import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dbs/constants/auth.dart';
import 'package:dbs/constants/firestore.dart';
import 'package:dbs/customisedwidgets/buttons/primarybutton.dart';
import 'package:dbs/customisedwidgets/buttons/secondarybutton.dart';
import 'package:dbs/customisedwidgets/textinputs/custominput.dart';
import 'package:dbs/customisedwidgets/texts/black.dart';
import 'package:dbs/redux/actions/useractions.dart';
import 'package:dbs/redux/appstate.dart';
import 'package:dbs/screens/home/home.dart';
import 'package:dbs/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:redux/redux.dart';

import '../../main.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

enum usertype { patient, pharmacy }

class _SignupState extends State<Signup> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController digitalController = TextEditingController();
  List user_type = ['patient', 'pharmacy'];
  String user = 'patient';
  bool done = false;
  bool buttonState = false;
  bool visible = false;
  bool googleSignin = false;

  //errors
  TextInputError? nameError;
  TextInputError? emailError;
  TextInputError? digitalError;
  TextInputError? passwordError;
  bool googleloading = false;
  UserCredential? userCredential;

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Visibility(
                visible: !done,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      child: Image.asset('lib/assets/logo.png'),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: BlackText(
                        text: 'for a better tomorrow',
                        size: 25,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05,
                          bottom: MediaQuery.of(context).size.height * 0.05),
                      alignment: Alignment.center,
                      child: BlackText(
                        text: 'Please enter your credentials to register',
                        size: 25,
                        weight: FontWeight.normal,
                      ),
                    ),
                    CustomInput(
                        error: emailError,
                        controller: emailController,
                        hint: 'Email'),
                    CustomInput(
                      controller: passwordController,
                      hint: 'Password',
                      margin: EdgeInsets.only(top: 15),
                      error: passwordError,
                      obscureText: !visible,
                      suffixIcon: IconButton(
                          color: DefaultColors.black,
                          onPressed: () {
                            setState(() {
                              visible = !visible;
                            });
                          },
                          icon: Icon(visible
                              ? Icons.visibility
                              : Icons.visibility_off)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 10),
                      width: MediaQuery.of(context).size.width,
                      child: PrimaryButton(
                        buttonText: 'Signup',
                        onPressed: () {
                          if (emailController.text.trim().length > 6 &&
                              emailController.text.contains('@') &&
                              emailController.text.contains('.') &&
                              passwordController.text.length > 7) {
                            errors();
                            setState(() {
                              done = true;
                            });
                          } else {
                            errors();
                          }
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                          color: DefaultColors.black,
                        )),
                        Expanded(
                          child: Container(
                              alignment: Alignment.center,
                              child: BlackText(
                                text: 'OR',
                              )),
                        ),
                        Expanded(
                            child: Divider(
                          color: DefaultColors.black,
                        )),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 15, top: 10),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5)),
                            backgroundColor:
                                MaterialStateProperty.all(DefaultColors.white),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        onPressed: googleloading
                            ? null
                            : () async {
                                setState(() {
                                  googleloading = true;
                                });
                                try {
                                  UserCredential? userCred =
                                      await signInWithGoogle();
                                  if (userCred != null) {
                                    if (userCred.user != null) {
                                      db
                                          .collection('users')
                                          .doc(userCred.user!.uid)
                                          .get()
                                          .then((value) async {
                                        if (value.exists) {
                                          _showMyDialogError(
                                              message:
                                                  'An account already exists for that email');
                                          setState(() {
                                            userCredential = null;
                                            googleSignin = false;
                                            done = false;
                                            buttonState = false;
                                          });
                                          if ((await GoogleSignIn()
                                              .isSignedIn())) {
                                            await GoogleSignIn().disconnect();
                                          }
                                        } else {
                                          setState(() {
                                            googleSignin = true;
                                            userCredential = userCred;
                                            googleloading = false;
                                            done = true;
                                            emailController.text =
                                                userCredential!.user!.email!;
                                          });
                                        }
                                      }).catchError((error) {
                                        _showMyDialogError(
                                            message: error.toString());
                                      });
                                    } else {
                                      alert(message: "User not found");
                                    }
                                  } else {}
                                } catch (error) {
                                  print(error);
                                  alert(message: error.toString());
                                }

                                setState(() {
                                  googleloading = false;
                                });
                              },
                        child: googleloading
                            ? Container(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      DefaultColors.black),
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Icon(Icons.goog)
                                  Container(
                                    margin: EdgeInsets.only(left: 25),
                                    width: 25,
                                    height: 25,
                                    child: Image.asset(
                                        'lib/assets/google_logo.png'),
                                  ),
                                  BlackText(
                                    text: 'Sign up with Google',
                                    size: 22,
                                    weight: FontWeight.normal,
                                  )
                                ],
                              ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BlackText(
                          text: "Already have an account?",
                        ),
                        SecondaryButton(
                          text: 'Sign in',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  ],
                )),
            Visibility(
                visible: done,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () async {
                          if ((await GoogleSignIn().isSignedIn())) {
                            await GoogleSignIn().disconnect();
                          }
                          setState(() {
                            done = false;
                            googleSignin = false;
                          });
                        },
                        icon: Icon(Icons.arrow_back)),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 50, bottom: 40),
                      child: BlackText(
                        text: 'Few settings to go...',
                        size: 25,
                      ),
                    ),
                    CustomInput(
                      controller: nameController,
                      hint: 'Name',
                      margin: EdgeInsets.only(top: 15),
                      error: nameError,
                    ),
                    CustomInput(
                      controller: digitalController,
                      hint: 'Digital Address',
                      margin: EdgeInsets.only(top: 15),
                      error: digitalError,
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(top: 20),
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.business),
                    //       Container(
                    //         margin: EdgeInsets.only(left: 20),
                    //         child: BlackText(
                    //           text: 'User type',
                    //           size: 25,
                    //           weight: FontWeight.normal,
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    // ...user_type
                    //     .map((e) => Container(
                    //           child: Row(
                    //             children: [
                    //               Radio<String>(
                    //                 activeColor: DefaultColors.green,
                    //                 value: e,
                    //                 onChanged: (String? value) {
                    //                   setState(() {
                    //                     user = value!;
                    //                   });
                    //                 },
                    //                 groupValue: user,
                    //               ),
                    //               Container(
                    //                 child: BlackText(text: e),
                    //               )
                    //             ],
                    //           ),
                    //         ))
                    //     .toList(),
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1,
                          bottom: 30),
                      width: MediaQuery.of(context).size.width,
                      child: PrimaryButton(
                        indicator: buttonState,
                        buttonText: 'Create',
                        onPressed: !buttonState
                            ? () {
                                if (googleSignin) {
                                  setState(() {
                                    buttonState = true;
                                  });
                                  postUserdata(id: userCredential!.user!.uid);
                                } else {
                                  if (nameController.text.trim().length > 2 &&
                                      emailController.text.trim().length > 6 &&
                                      emailController.text.contains('@') &&
                                      emailController.text.contains('.') &&
                                      passwordController.text.length > 7) {
                                    errors();
                                    // congrats();
                                    createUser();
                                  } else {
                                    // congrats();
                                    errors();
                                  }
                                }
                              }
                            : null,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        BlackText(
                          text: "By creating this account, you agree to our",
                        ),
                        SecondaryButton(
                          onPressed: () {},
                          text: 'Sign in',
                          padding: EdgeInsets.zero,
                        ),
                        BlackText(text: 'and'),
                        SecondaryButton(
                          onPressed: () {},
                          text: 'Privacy Policy',
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ))
          ],
        ),
      ),
    ));
  }

  Future<void> alert({String message = ''}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Alert')],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  color: Colors.red,
                  child:
                      Lottie.asset('lib/lottiefiles/alert.json', height: 100),
                ),
                BlackText(text: message),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: BlackText(
                    text: 'Press OK to make changes and try again',
                    weight: FontWeight.normal,
                    size: 14,
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future createUser() async {
    setState(() {
      buttonState = true;
    });
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: emailController.text.toLowerCase().trim(),
          password: passwordController.text);
      if (userCredential.user != null) {
        userCredential.user!.updateDisplayName(
          nameController.text.trim(),
        );
        // userCredential.user!.updatePhoneNumber(phoneCredential)
        postUserdata(id: userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        buttonState = false;
      });
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        _showMyDialogError(message: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        // print('The account already exists for that email.');
        setState(() {
          emailError = TextInputError(
              visible: true,
              message: 'An account already exists for the email provided');
        });
        // postUserdata();
        _showMyDialogError(message: 'An account already exists for that email');
      }
    } catch (e) {
      _showMyDialogError(message: e.toString());
      print(e);
    }
  }

  void postUserdata({required String id}) {
    DocumentReference userRef = db.collection('users').doc(id);

    userRef.set({
      'name': nameController.text.trim(),
      'email': emailController.text.toLowerCase().trim(),
      'is_active': true,
      'digital_address': digitalController.text.trim(),
      'type': user,
      'roles': ['USER'],
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'id': id,
    }).then((value) {
      setState(() {
        buttonState = false;
      });
      getIt.get<Store<AppState>>().dispatch(GetUserAction(uid: id));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
          (route) => false);
    }).catchError((error) {
      setState(() {
        buttonState = false;
      });
      _showMyDialogError(message: error.toString());
    });
  }

  Future<void> _showMyDialogError({String message = ''}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Alert')],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  color: Colors.red,
                  child:
                      Lottie.asset('lib/lottiefiles/alert.json', height: 100),
                ),
                BlackText(text: message),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: BlackText(
                    text: 'Press OK to make changes and try again',
                    weight: FontWeight.normal,
                    size: 14,
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  errors() {
    setState(() {
      nameError = TextInputError(
          visible: done && nameController.text.trim().length < 3 ? true : false,
          message: nameController.text.trim().length < 3
              ? 'Name must be 3 or more characters'
              : '');
      emailError = TextInputError(
          visible: emailController.text.trim().length < 7 ||
              !emailController.text.contains('.') ||
              !emailController.text.contains('@'),
          message: emailController.text.trim().length < 7
              ? 'Email must be more than 6 characters'
              : !emailController.text.contains('.')
                  ? 'Email must contain .'
                  : !emailController.text.contains('@')
                      ? 'Email must contain @'
                      : '');
      passwordError = TextInputError(
          visible: passwordController.text.length < 8,
          message: passwordController.text.length < 8
              ? 'Password must be 8 or more characters'
              : '');
    });
  }
}

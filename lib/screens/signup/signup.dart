import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:redux/redux.dart';

import '../../constants/auth.dart';
import '../../constants/firestore.dart';
import '../../customisedwidgets/buttons/primarybutton.dart';
import '../../customisedwidgets/buttons/secondarybutton.dart';
import '../../customisedwidgets/textinputs/custominput.dart';
import '../../customisedwidgets/texts/black.dart';
import '../../main.dart';
import '../../redux/actions/useractions.dart';
import '../../redux/appstate.dart';
import '../../theme/colors.dart';
import '../home/home.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

enum UserType { patient, pharmacy }

class _SignupState extends State<Signup> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController digitalController = TextEditingController();
  List userTypes = ['patient', 'pharmacy'];
  String user = 'patient';
  bool done = false;
  bool buttonState = false;
  bool visible = false;
  bool googleSignIn = false;

  //errors
  TextInputError? nameError;
  TextInputError? emailError;
  TextInputError? digitalError;
  TextInputError? passwordError;
  bool googleLoading = false;
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
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Visibility(
                visible: !done,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      child: Image.asset('lib/assets/logo.png'),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: const BlackText(
                        text: 'for a better tomorrow',
                        size: 25,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05,
                          bottom: MediaQuery.of(context).size.height * 0.05),
                      alignment: Alignment.center,
                      child: const BlackText(
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
                      margin: const EdgeInsets.only(top: 15),
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
                      margin: const EdgeInsets.only(top: 20, bottom: 10),
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
                        const Expanded(
                            child: Divider(
                          color: DefaultColors.black,
                        )),
                        Expanded(
                          child: Container(
                              alignment: Alignment.center,
                              child: const BlackText(
                                text: 'OR',
                              )),
                        ),
                        const Expanded(
                            child: Divider(
                          color: DefaultColors.black,
                        )),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 15, top: 10),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5)),
                            backgroundColor:
                                WidgetStateProperty.all(DefaultColors.white),
                            shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        onPressed: googleLoading
                            ? null
                            : () async {
                                setState(() {
                                  googleLoading = true;
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
                                            googleSignIn = false;
                                            done = false;
                                            buttonState = false;
                                          });
                                          if ((await GoogleSignIn()
                                              .isSignedIn())) {
                                            await GoogleSignIn().disconnect();
                                          }
                                        } else {
                                          setState(() {
                                            googleSignIn = true;
                                            userCredential = userCred;
                                            googleLoading = false;
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
                                  log("error: $error");
                                  alert(message: error.toString());
                                }

                                setState(() {
                                  googleLoading = false;
                                });
                              },
                        child: googleLoading
                            ? const SizedBox(
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
                                    margin: const EdgeInsets.only(left: 25),
                                    width: 25,
                                    height: 25,
                                    child: Image.asset(
                                        'lib/assets/google_logo.png'),
                                  ),
                                  const BlackText(
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
                        const BlackText(
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
                            googleSignIn = false;
                          });
                        },
                        icon: const Icon(Icons.arrow_back)),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 50, bottom: 40),
                      child: const BlackText(
                        text: 'Few settings to go...',
                        size: 25,
                      ),
                    ),
                    CustomInput(
                      controller: nameController,
                      hint: 'Name',
                      margin: const EdgeInsets.only(top: 15),
                      error: nameError,
                    ),
                    CustomInput(
                      controller: digitalController,
                      hint: 'Digital Address',
                      margin: const EdgeInsets.only(top: 15),
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
                                if (googleSignIn) {
                                  setState(() {
                                    buttonState = true;
                                  });
                                  postUserData(id: userCredential!.user!.uid);
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
                        const BlackText(
                          text: "By creating this account, you agree to our",
                        ),
                        SecondaryButton(
                          onPressed: () {},
                          text: 'Sign in',
                          padding: EdgeInsets.zero,
                        ),
                        const BlackText(text: 'and'),
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
          title: const Row(
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
                  margin: const EdgeInsets.only(top: 15),
                  child: const BlackText(
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
              child: const Text('OK'),
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
        postUserData(id: userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        buttonState = false;
      });
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
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

  void postUserData({required String id}) {
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
            builder: (context) => const Home(),
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
          title: const Row(
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
                  margin: const EdgeInsets.only(top: 15),
                  child: const BlackText(
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
              child: const Text('OK'),
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

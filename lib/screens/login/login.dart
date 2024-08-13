import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:redux/redux.dart';

import '../../constants/firestore.dart';
import '../../customisedwidgets/buttons/primarybutton.dart';
import '../../customisedwidgets/buttons/secondarybutton.dart';
import '../../customisedwidgets/textinputs/custominput.dart';
import '../../customisedwidgets/texts/black.dart';
import '../../data/user.dart';
import '../../main.dart';
import '../../redux/actions/useractions.dart';
import '../../redux/appstate.dart';
import '../../theme/colors.dart';
import '../forgotpassword/forgotpassword.dart';
import '../home/home.dart';
import '../signup/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool visible = false;
  bool loading = false;
  bool googleLoading = false;
  TextInputError? emailError;

  TextInputError? passwordError;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
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
                  text: 'Please login to continue',
                  size: 25,
                  weight: FontWeight.normal,
                ),
              ),
              CustomInput(
                controller: emailController,
                hint: 'Email',
                error: emailError,
              ),
              CustomInput(
                controller: passwordController,
                error: passwordError,
                hint: 'Password',
                margin: const EdgeInsets.only(top: 15),
                obscureText: !visible,
                suffixIcon: IconButton(
                    color: DefaultColors.black,
                    onPressed: () {
                      setState(() {
                        visible = !visible;
                      });
                    },
                    icon: Icon(
                        visible ? Icons.visibility : Icons.visibility_off)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                width: MediaQuery.of(context).size.width,
                child: PrimaryButton(
                  buttonText: 'Login',
                  indicator: loading,
                  onPressed: !loading
                      ? () {
                          if (emailController.text.trim().length > 6 &&
                              emailController.text.contains('@') &&
                              emailController.text.contains('.') &&
                              passwordController.text.length > 7) {
                            errors();
                            // congrats();
                            login();
                          } else {
                            errors();
                          }

                          // setState(() {
                          //   code = '1223';
                          // });
                        }
                      : null,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const BlackText(
                    text: 'Forgot password?',
                  ),
                  SecondaryButton(
                    text: 'Reset',
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50))),
                        context: context,
                        builder: (context) => const ForgotPassword(),
                      );
                    },
                  )
                ],
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
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
                  onPressed: googleLoading
                      ? null
                      : () async {
                          setState(() {
                            googleLoading = true;
                          });
                          try {
                            UserCredential? userCred = await signInWithGoogle();
                            log(userCred.toString(), name: 'User Cred');
                            if (userCred != null) {
                              if (userCred.user != null) {
                                getUserData(uid: userCred.user?.uid ?? "");
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
                            valueColor:
                                AlwaysStoppedAnimation(DefaultColors.black),
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Icon(Icons.goog)
                            Container(
                              margin: const EdgeInsets.only(left: 25),
                              width: 25,
                              height: 25,
                              child: Image.asset('lib/assets/google_logo.png'),
                            ),
                            const BlackText(
                              text: 'Login with Google',
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
                    text: "Don't have an account?",
                  ),
                  SecondaryButton(
                    text: 'Sign up',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Signup(),
                          ));
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      )),
      onWillPop: () async {
        await showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Close Application')],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      child: const BlackText(
                        text: "You are about to close this App. Proceed?",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SecondaryButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          text: 'NO',
                          color: Colors.red,
                        ),
                        PrimaryButton(
                          onPressed: () {
                            exit(0);
                          },
                          buttonText: 'YES',
                        )
                      ],
                    )
                  ],
                ),
              );
            });
        return false;
      },
    );
  }

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

  Future login() async {
    setState(() {
      loading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text.toLowerCase().trim(),
              password: passwordController.text.trim());
      setState(() {
        loading = false;
      });
      if (userCredential.user != null) {
        getUserData(uid: userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      if (e.code == 'user-not-found') {
        // print('No user found for that email.');
        alert(message: 'No user found for that email');
      } else if (e.code == 'wrong-password') {
        // log('Wrong password provided for that user.');
        alert(message: 'Wrong password provided for the email');
      } else {
        // getUserData(uid: );
        alert(message: e.code);
      }
      // log(e.message!, name: 'error auth');
      // return 'error';
    }
  }

  void getUserData({required String uid}) {
    db
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) async {
      // log('successful');
      if (snapshot.exists) {
        // registerToTipsTopic();

        UserModel userModel = UserModel.fromJson(snapshot.data()!);
        if (userModel.isActive) {
          getIt
              .get<Store<AppState>>()
              .dispatch(GetUserAction(uid: userModel.id));

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(),
              ),
            );
          }
        } else {
          if ((await GoogleSignIn().isSignedIn())) {
            await GoogleSignIn().disconnect();
          }
          alert(
              message:
                  'Your account has been deactivated, contact our team for support');
        }
      } else {
        alert(message: 'User not found, create an account');
        if ((await GoogleSignIn().isSignedIn())) {
          await GoogleSignIn().disconnect();
        }
      }
    });
    setState(() {
      loading = false;
    });
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

  errors() {
    setState(() {
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

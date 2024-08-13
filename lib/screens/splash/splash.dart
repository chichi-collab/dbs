import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import '../../constants/firestore.dart';
import '../../customisedwidgets/texts/black.dart';
import '../../data/user.dart';
import '../../main.dart';
import '../../redux/actions/useractions.dart';
import '../../redux/appstate.dart';
import '../home/home.dart';
import '../login/login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Image.asset('lib/assets/logo_2.png'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child:
                  // ConstrainedBox(
                  //   constraints: BoxConstraints(
                  //       maxWidth: MediaQuery.of(context).size.width * 1),
                  //   child:
                  const BlackText(
                text: 'Drug Distribution System',
                size: 55,
              ),
              // )
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                'lib/assets/splash_shape.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
            )
          ],
        ),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    // getIt.get<Store<AppState>>().dispatch(GetUserLocation());

    Timer(const Duration(milliseconds: 3000), () {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          log('User is currently signed out!');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Login(),
            ),
          );
        } else {
          log('User is signed in!');
          db
              .collection('users')
              .doc(user.uid)
              .get()
              .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
            // log('successful');
            if (snapshot.exists) {
              UserModel userModel = UserModel.fromJson(snapshot.data()!);
              if (userModel.isActive) {
                getIt
                    .get<Store<AppState>>()
                    .dispatch(GetUserAction(uid: userModel.id));
                // getIt
                //     .get<Store<AppState>>()
                //     .dispatch(HideNavBarAction(hidebar: false));
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Home(),
                    ),
                  );
                }
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                );
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
              );
            }
          });
        }
      });
    });
  }
}

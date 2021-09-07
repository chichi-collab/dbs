import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dbs/constants/firestore.dart';
import 'package:dbs/customisedwidgets/textinputs/custominput.dart';
import 'package:dbs/customisedwidgets/texts/black.dart';
import 'package:dbs/data/user.dart';
import 'package:dbs/redux/actions/useractions.dart';
import 'package:dbs/redux/appstate.dart';
import 'package:dbs/screens/home/home.dart';
import 'package:dbs/screens/login/login.dart';
import 'package:dbs/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import '../../main.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
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
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Image.asset('lib/assets/logo_2.png'),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child:
                  // ConstrainedBox(
                  //   constraints: BoxConstraints(
                  //       maxWidth: MediaQuery.of(context).size.width * 1),
                  //   child:
                  BlackText(
                text: 'Drug Distribution System',
                size: 55,
              ),
              // )
            ),
            Container(
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

    Timer(Duration(milliseconds: 3000), () {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          print('User is currently signed out!');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Login(),
            ),
          );
        } else {
          print('User is signed in!');
          db
              .collection('users')
              .doc(user.uid)
              .get()
              .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
            // log('successful');
            if (snapshot.exists) {
              UserModel userModel = UserModel.fromJson(snapshot.data()!);
              if (userModel.is_active) {
                getIt
                    .get<Store<AppState>>()
                    .dispatch(GetUserAction(uid: userModel.id));
                // getIt
                //     .get<Store<AppState>>()
                //     .dispatch(HideNavBarAction(hidebar: false));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ),
              );
            }
          });
        }
      });
    });
  }
}

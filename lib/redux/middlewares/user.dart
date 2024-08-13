import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:redux/redux.dart';

import '../../constants/firestore.dart';
import '../../data/products.dart';
import '../../data/user.dart';
import '../actions/useractions.dart';
import '../appstate.dart';

Future<void> saveTokenToDatabase(String token, {String? userId}) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'tokens': FieldValue.arrayUnion([token]),
  });
}

Future<void> listenToToken(String userId) async {
  String token = (await FirebaseMessaging.instance.getToken())!;

  // Save the initial token to the database
  await saveTokenToDatabase(token, userId: userId);

  // Any time the token refreshes, store this in the database too.
  FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
}

void fetchUser(Store<AppState> store, action, NextDispatcher next) {
  // If our Middleware encounters a `FetchTodoAction`
  if (action is GetUserAction) {
    listenToToken(action.uid!);
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshotsProducts = db
        .collection('products')
        .where('is_active', isEqualTo: true)
        .snapshots();
    querySnapshotsProducts
        .listen((QuerySnapshot<Map<String, dynamic>> element) {
      List<Product> initProduct = [];
      log(element.size.toString(), name: 'products size');
      if (element.size > 0) {
        for (var element in element.docs) {
          Product prod = Product.fromJson(element.data());
          initProduct.add(prod);
        }
      }
      store.dispatch(GetProductActionSuccess(products: initProduct));
    });
    Stream<DocumentSnapshot<Map<String, dynamic>>> querySnapshots =
        db.collection('users').doc(action.uid).snapshots();
    querySnapshots.listen((DocumentSnapshot<Map<String, dynamic>> element) {
      // log('i  ran', name: element.data().toString());

      UserModel userData = UserModel.fromJson(element.data()!);
      store.dispatch(GetUserActionSuccess(user: userData));
    });
  }

  // Make sure our actions continue on to the reducer.
  next(action);
}

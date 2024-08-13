import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:get_it/get_it.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'data/notification.dart';
import 'redux/appstate.dart';
import 'redux/middlewares/user.dart';
import 'redux/reducer.dart';
import 'screens/splash/splash.dart';

GetIt getIt = GetIt.instance;
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.max,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

const MethodChannel platform = MethodChannel('high_importance_channel');
String? selectedNotificationPayload;

void main() async {
  final Store<AppState> store = Store(
    appStateReducer,
    middleware: [
      fetchUser,
    ],
    initialState: AppState(),
  );
  getIt.registerSingleton<Store<AppState>>(store, signalsReady: true);
  WidgetsFlutterBinding.ensureInitialized();
  // await _configureLocalTimeZone();
  if (Platform.isAndroid || Platform.isIOS) {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    // String initialRoute = HomePage.routeName;
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      // selectedNotificationPayload = notificationAppLaunchDetails!.payload;
      // initialRoute = SecondPage.routeName;
    }
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onDidReceiveNotificationResponse: (String? payload) async {
    //   if (payload != null) {
    //     debugPrint('notification payload: $payload');
    //   }
    //   selectedNotificationPayload = payload;
    //   selectNotificationSubject.add(payload!);
    // });
  }
  runApp(MyApp(
    store: store,
  ));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  // This widget is the root of your application.
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  MyApp({super.key, required this.store});

// TODO :

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'DDS',
        home: FutureBuilder(
          // Initialize FlutterFire:
          future: _initialization,
          builder: (context, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return const Text('An Error occurred');
            }

            // Once complete, show your application
            if (snapshot.connectionState == ConnectionState.done) {
              return const Splash();
            }

            // Otherwise, show something whilst waiting for initialization to complete
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String? timeZoneName =
      await platform.invokeMethod<String>('getTimeZoneName');
  // log(timeZoneName);
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

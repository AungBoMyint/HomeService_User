import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../screens/booking/booking_detail_screen.dart';
import '../utils/constant.dart';

class FirebaseMessagingService {
  void getToken() {
    FirebaseMessaging.instance.getToken().then((playerID) async {
      if (!(playerID == null)) {
        // ignore: deprecated_member_use
        setStringAsync(PLAYERID, playerID);
        await appStore.setPlayerId(playerID);
        log("===========Token is $playerID");
      } else {
        log("============Token is null====");
      }
    });
  }

  Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    //for iOS Foreground
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> setUpFullNotification() async {
    //----For Local Notification
    //---when user tap to Notification,this method is called.
    void onDidReceiveNotificationResponse(
        NotificationResponse notificationResponse) async {
      String? notId = notificationResponse.payload;
      if (notId.validate().isNotEmpty) {
        BookingDetailScreen(bookingId: notId.toString().toInt())
            .launch(navigatorKey.currentContext!);
      }
    }

    //---Intilization to Show Local Notification
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_onesignal_default');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(onDidReceiveLocalNotification: null);
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
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
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    //for foreground notification listen
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              // other properties...
            ),
          ),
          payload: message.data["bookingId"],
        );
      }
    });

    //----SetUp for Backgorund,Terminated State Notification---//

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (!(initialMessage == null)) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    String? notId = message.data["bookingId"];
    if (notId.validate().isNotEmpty) {
      BookingDetailScreen(bookingId: notId.toString().toInt())
          .launch(navigatorKey.currentContext!);
    }
  }

  void listenToken(String email) {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await userService.userByEmail(email).then((value) {
        userService.ref!.doc(value.uid.validate()).update({
          'player_id': token,
        });
      });
    });
  }
}

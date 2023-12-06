import 'package:chucker_flutter/src/helpers/shared_preferences_manager.dart';
import 'package:chucker_flutter/src/view/api_detail_page.dart';
import 'package:chucker_flutter/src/view/helper/chucker_ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class NotificationBar {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  late Map<int, DateTime> _requestTimesId;

  NotificationBar(){
    _requestTimesId = Map<int, DateTime>();
  }

  int _id = 0;
  late DateTime _requestTime;

  void initializeNotificationsPlugin() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("app_icon");
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettingsMacOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response,
      ) async {
    assert(response.payload != null, "payload can't be null");
    _openDetails(response.id ?? 0);
    return;
  }

  Future<void> _openDetails(int id) async {
    DateTime _requestTime = _requestTimesId[id]!;

    final api = await SharedPreferencesManager.getInstance().getApiResponse(
      _requestTime,
    );
    await ChuckerFlutter.navigatorObserver.navigator?.push(
      MaterialPageRoute<dynamic>(builder: (_) => ApiDetailsPage(api: api)),
    );
  }

  Future<void> showLocalNotification(String method, String path,String messageNotif, DateTime requestTime) async {
    _id = _id + 1;
    _requestTime = requestTime;
    _requestTimesId.addAll({_id:_requestTime});
    const channelId = 'Flutter Chucker';
    const channelName = 'Flutter Chucker';
    const channelDescription = 'Flutter Chucker';
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      enableVibration: true,
      priority: Priority.defaultPriority,
      playSound: true,
    );
    const iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(presentSound: false);
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    final message = messageNotif;
    await _flutterLocalNotificationsPlugin.show(
      _id,
      '${method.toUpperCase()} : $path',
      message,
      platformChannelSpecifics,
      payload: '',
    );
    return;
  }

}



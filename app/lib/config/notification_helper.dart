import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../model/user.dart';

class LocalNotification {
  static final FlutterLocalNotificationsPlugin _notiPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize() {
    final InitializationSettings initialSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
      iOS: DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true)
    );



    _notiPlugin.initialize(initialSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          print('onDidReceiveNotificationResponse Function');
          print(details.payload);
          print(details.payload != null);
        });
  }

  static void showNotification(RemoteMessage message) {

    // {titulo: Atualização do status do pedido, type: new_ticket, descricao: O pedido de número #212 foi atualizado para Enviado}

    User notification = User.fromJson(message.data);

    final NotificationDetails notiDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'com.aguadaserra.app.push_notification',
        'push_notification',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(

      )
    );
    _notiPlugin.show(
      DateTime.now().microsecond,
      notification.titulo,
      notification.descricao,
      notiDetails,
      payload: message.data.toString(),
    );
  }
}
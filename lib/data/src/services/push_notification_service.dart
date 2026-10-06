import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:colabhealth/core/src/utils/app_logger.dart';
import 'package:colabhealth/data/src/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.print('BG push received: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  String? token;

  Future<void> init() async {
    try {
      await _fm.requestPermission(alert: true, badge: true, sound: true);

      await _fm.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);

      token = await _fm.getToken();
      AppLogger.print('================ FCM TOKEN ================');
      AppLogger.print(token);
      AppLogger.print('==========================================');

      _fm.onTokenRefresh.listen((t) {
        token = t;
        AppLogger.print('FCM token refreshed: $t');
      });

      FirebaseMessaging.onMessage.listen((message) {
        final n = message.notification;
        AppLogger.print('FG push: ${n?.title} / ${n?.body}');
        if (n != null) {
          NotificationService.instance.showRemote(
            title: n.title ?? 'Colab Health',
            body: n.body ?? '',
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        AppLogger.print('Notification tapped: ${message.messageId}');
      });
    } catch (e) {
      AppLogger.error('PushNotificationService.init', error: e);
    }
  }

  Future<String?> refreshToken() async {
    token = await _fm.getToken();
    return token;
  }
}

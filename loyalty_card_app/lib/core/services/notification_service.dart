import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyalty_card_app/shared/models/card_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static FlutterLocalNotificationsPlugin? _notifications;

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize() async {
    _notifications = FlutterLocalNotificationsPlugin();
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications!.initialize(initSettings);
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  Future<void> scheduleCardExpiryNotification(CardModel card) async {
    if (!await areNotificationsEnabled()) return;
    if (card.expiryDate == null) return;

    final now = DateTime.now();
    final daysUntilExpiry = card.expiryDate!.difference(now).inDays;

    // Only schedule if expiry is within 30 days
    if (daysUntilExpiry > 30 || daysUntilExpiry < 0) return;

    final notificationId = card.id.hashCode;
    final title = 'Card Expiring Soon';
    final body = '${card.name} expires in $daysUntilExpiry days';

    await _notifications!.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(card.expiryDate!, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'card_expiry',
          'Card Expiry Notifications',
          channelDescription: 'Notifications for expiring loyalty cards',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelCardExpiryNotification(CardModel card) async {
    final notificationId = card.id.hashCode;
    await _notifications?.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications?.cancelAll();
  }
} 
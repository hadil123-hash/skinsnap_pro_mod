import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _routineChannelId = 'skinsnap_routine_channel';
  static const String _routineChannelName = 'Routine SkinSnap';
  static const String _routineChannelDesc = 'Rappels quotidiens pour la routine SkinSnap';

  bool _initialized = false;

  bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> init() async {
    if (!isSupported || _initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Casablanca'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _routineChannelId,
        _routineChannelName,
        description: _routineChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await init();

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? true;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? true;
      }

      return false;
    } catch (error) {
      debugPrint('Erreur permission notifications: $error');
      return false;
    }
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _routineChannelId,
          _routineChannelName,
          channelDescription: _routineChannelDesc,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!isSupported) return;
    await init();

    try {
      await _plugin.show(id, title, body, _details);
    } catch (error) {
      debugPrint('Erreur affichage notification: $error');
    }
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    if (!isSupported) return;
    await init();

    try {
      await _plugin.cancel(id);
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error) {
      debugPrint('Erreur programmation notification: $error');
    }
  }

  Future<void> scheduleReEngagementReminder({
    required String title,
    required String body,
    Duration delay = const Duration(hours: 24),
  }) async {
    if (!isSupported) return;
    await init();

    try {
      await _plugin.cancel(30);
      final scheduled = tz.TZDateTime.now(tz.local).add(delay);
      await _plugin.zonedSchedule(
        30,
        title,
        body,
        scheduled,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      );
    } catch (error) {
      debugPrint('Erreur re-engagement notification: $error');
    }
  }

  Future<void> scheduleRoutinePack({
    required String morningTitle,
    required String morningBody,
    required String eveningTitle,
    required String eveningBody,
    required String reengageTitle,
    required String reengageBody,
  }) async {
    if (!isSupported) return;
    await init();
    await scheduleDailyReminder(
      id: 10,
      title: morningTitle,
      body: morningBody,
      time: const TimeOfDay(hour: 8, minute: 0),
    );
    await scheduleDailyReminder(
      id: 20,
      title: eveningTitle,
      body: eveningBody,
      time: const TimeOfDay(hour: 20, minute: 0),
    );
    await scheduleReEngagementReminder(
      title: reengageTitle,
      body: reengageBody,
      delay: const Duration(hours: 36),
    );
  }

  Future<void> onRoutineCompleted({
    required bool morning,
    required String title,
    required String body,
    required String nextTitle,
    required String nextBody,
  }) async {
    if (!isSupported) return;
    await init();
    await showNow(id: morning ? 110 : 120, title: title, body: body);
    await scheduleReEngagementReminder(
      title: nextTitle,
      body: nextBody,
      delay: const Duration(hours: 20),
    );
  }

  Future<void> cancelAll() async {
    if (!isSupported) return;
    await init();
    try {
      await _plugin.cancelAll();
    } catch (error) {
      debugPrint('Erreur annulation notifications: $error');
    }
  }
}

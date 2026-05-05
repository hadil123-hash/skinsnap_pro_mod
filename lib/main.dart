import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'providers/beauty_plan_provider.dart';
import 'screens/root_screen.dart';
import 'services/notification_service.dart';
import 'services/sound_service.dart';
import 'utils/constants.dart';
import 'utils/translations.dart';

bool get _isPhonePlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!_isPhonePlatform) {
    runApp(const PhoneOnlyApp());
    return;
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (error) {
    if (error.code == 'duplicate-app') {
      debugPrint('Firebase est deja initialise, on continue...');
    } else {
      runApp(FirebaseSetupRequiredApp(error: error.toString()));
      return;
    }
  } catch (error) {
    runApp(FirebaseSetupRequiredApp(error: error.toString()));
    return;
  }

  final AppProvider appProvider = AppProvider();
  await appProvider.init();

  final BeautyPlanProvider beautyProvider = BeautyPlanProvider();
  await beautyProvider.init();

  final NotificationService notificationService = NotificationService();

  try {
    await notificationService.init();

    final bool notificationsGranted =
        await notificationService.requestPermission();

    if (notificationService.isSupported &&
        appProvider.notificationsOn &&
        notificationsGranted) {
      await notificationService.scheduleRoutinePack(
        morningTitle: 'Routine du matin ☀️',
        morningBody: 'Pense à faire ta routine SkinSnap pour bien commencer la journée.',
        eveningTitle: 'Routine du soir 🌙',
        eveningBody: 'C’est le bon moment pour compléter ta routine du soir.',
        reengageTitle: 'SkinSnap vous attend ✨',
        reengageBody: 'Reviens découvrir ta routine, tes produits et tes conseils personnalisés.',
      );
    }
  } catch (error) {
    debugPrint('Erreur notifications: $error');
  }

  SoundService().configure(
    sound: appProvider.soundOn,
    vibration: appProvider.vibrationOn,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>.value(value: appProvider),
        ChangeNotifierProvider<BeautyPlanProvider>.value(value: beautyProvider),
      ],
      child: const SkinSnapApp(),
    ),
  );
}

class SkinSnapApp extends StatelessWidget {
  const SkinSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppProvider app = context.watch<AppProvider>();

    SoundService().configure(
      sound: app.soundOn,
      vibration: app.vibrationOn,
    );

    return MaterialApp(
      title: 'SkinSnap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: app.themeMode,
      locale: app.locale,
      supportedLocales: AppLocales.all,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final bool isRtl = AppLocales.isRtl(app.locale);
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const RootScreen(),
    );
  }
}

class PhoneOnlyApp extends StatelessWidget {
  const PhoneOnlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinSnap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _BlockedScreen(
        title: 'Application mobile uniquement',
        message:
            'SkinSnap est volontairement limitee aux telephones Android et iOS. Lancez le projet avec un emulateur Android/iOS ou un vrai telephone.',
        icon: Icons.phone_iphone_rounded,
      ),
    );
  }
}

class FirebaseSetupRequiredApp extends StatelessWidget {
  const FirebaseSetupRequiredApp({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinSnap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: _BlockedScreen(
        title: 'Configuration Firebase requise',
        message:
            'Firebase n a pas pu etre initialise. Verifiez que lib/firebase_options.dart et android/app/google-services.json existent. Detail: $error',
        icon: Icons.local_fire_department_rounded,
      ),
    );
  }
}

class _BlockedScreen extends StatelessWidget {
  const _BlockedScreen({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 390),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: .12),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.blush,
                  child: Icon(icon, color: AppColors.primaryDark, size: 36),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.5,
                    color: AppColors.onSurfaceLight.withValues(alpha: .72),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

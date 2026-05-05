import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import '../widgets/beauty_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _setNotifications(BuildContext context, bool value) async {
    final app = context.read<AppProvider>();
    final notifications = NotificationService();

    await SoundService().vibrateLight();

    if (value) {
      await notifications.init();

      final granted = await notifications.requestPermission();
      await app.setNotificationsOn(granted);

      if (granted) {
        await notifications.scheduleRoutinePack(
          morningTitle: 'Routine du matin ☀️',
          morningBody:
          'Pense à faire ta routine SkinSnap pour bien commencer la journée.',
          eveningTitle: 'Routine du soir 🌙',
          eveningBody:
          'C’est le bon moment pour compléter ta routine du soir.',
          reengageTitle: 'SkinSnap vous attend ✨',
          reengageBody:
          'Reviens découvrir ta routine, tes produits et tes conseils personnalisés.',
        );

        await notifications.showNow(
          id: 91,
          title: app.tr('notif_enabled_title'),
          body:
          'Les rappels automatiques sont activés pour ta routine et ton retour sur l’application.',
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              granted
                  ? app.tr('notifications_on')
                  : app.tr('notifications_denied'),
            ),
          ),
        );
      }
    } else {
      await notifications.cancelAll();
      await app.setNotificationsOn(false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(app.tr('notifications_off')),
          ),
        );
      }
    }
  }

  Future<void> _setSound(BuildContext context, bool value) async {
    final app = context.read<AppProvider>();

    await app.setSoundOn(value);

    SoundService().configure(
      sound: value,
      vibration: app.vibrationOn,
    );

    if (value) {
      await SoundService().playSuccess();
    }
  }

  Future<void> _setVibration(BuildContext context, bool value) async {
    final app = context.read<AppProvider>();

    await app.setVibrationOn(value);

    SoundService().configure(
      sound: app.soundOn,
      vibration: value,
    );

    if (value) {
      await SoundService().vibrateSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final tr = app.tr;

    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Row(
                children: [
                  BeautyCircleIcon(
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 44,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GradientText(
                      tr('settings'),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              BeautyCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: app.isDark,
                      onChanged: (_) async {
                        await SoundService().playClick();
                        await app.toggleTheme();
                      },
                      title: Text(
                        tr('dark_mode'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      secondary: const Icon(
                        Icons.dark_mode_rounded,
                        color: AppColors.hotPink,
                      ),
                    ),

                    SwitchListTile(
                      value: app.notificationsOn,
                      onChanged: (value) => _setNotifications(context, value),
                      title: Text(
                        tr('notifications'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: const Text(
                        'Notifications automatiques pour routine matin/soir et retour sur l’application.',
                      ),
                      secondary: const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.hotPink,
                      ),
                    ),

                    SwitchListTile(
                      value: app.soundOn,
                      onChanged: (value) => _setSound(context, value),
                      title: Text(
                        tr('sounds'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(tr('sounds_hint')),
                      secondary: const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.hotPink,
                      ),
                    ),

                    SwitchListTile(
                      value: app.vibrationOn,
                      onChanged: (value) => _setVibration(context, value),
                      title: Text(
                        tr('vibration'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(tr('vibration_hint')),
                      secondary: const Icon(
                        Icons.vibration_rounded,
                        color: AppColors.hotPink,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              BeautyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('language'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      tr('language_hint'),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _LangChip(
                          label: AppLocales.label(AppLocales.fr),
                          locale: AppLocales.fr,
                          current: app.locale,
                        ),
                        _LangChip(
                          label: AppLocales.label(AppLocales.en),
                          locale: AppLocales.en,
                          current: app.locale,
                        ),
                        _LangChip(
                          label: AppLocales.label(AppLocales.ar),
                          locale: AppLocales.ar,
                          current: app.locale,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.locale,
    required this.current,
  });

  final String label;
  final Locale locale;
  final Locale current;

  @override
  Widget build(BuildContext context) {
    final selected = locale.languageCode == current.languageCode;

    return ChoiceChip(
      selected: selected,
      label: Text(label),
      selectedColor: AppColors.hotPink,
      backgroundColor: AppColors.blush,
      side: BorderSide.none,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.hotPink,
        fontWeight: FontWeight.w900,
      ),
      onSelected: (_) async {
        await context.read<AppProvider>().setLocale(locale);
        await SoundService().feedbackSave();
      },
    );
  }
}
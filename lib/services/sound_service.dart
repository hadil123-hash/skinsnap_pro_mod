import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  void configure({required bool sound, required bool vibration}) {
    _soundEnabled = sound;
    _vibrationEnabled = vibration;
  }

  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> playError() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  Future<void> playClick() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> playSave() async {
    await playClick();
  }

  Future<void> vibrateLight() async {
    if (!_vibrationEnabled || kIsWeb) return;
    try {
      await HapticFeedback.selectionClick();
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) await Vibration.vibrate(duration: 70);
    } catch (_) {}
  }

  Future<void> vibrateSuccess() async {
    if (!_vibrationEnabled || kIsWeb) return;
    try {
      await HapticFeedback.mediumImpact();
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) await Vibration.vibrate(pattern: [0, 90, 50, 140]);
    } catch (_) {}
  }

  Future<void> vibrateError() async {
    if (!_vibrationEnabled || kIsWeb) return;
    try {
      await HapticFeedback.heavyImpact();
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) await Vibration.vibrate(pattern: [0, 280, 90, 280]);
    } catch (_) {}
  }

  Future<void> feedbackSuccess() async {
    await playSuccess();
    await vibrateSuccess();
  }

  Future<void> feedbackError() async {
    await playError();
    await vibrateError();
  }

  Future<void> feedbackSave() async {
    await playSave();
    await vibrateLight();
  }
}

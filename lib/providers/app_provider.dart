import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../utils/translations.dart';

class AppProvider extends ChangeNotifier {
  static const _kTheme = 'pref_theme';
  static const _kLocale = 'pref_locale';
  static const _kSound = 'pref_sound';
  static const _kVibration = 'pref_vibration';
  static const _kNotifications = 'pref_notifications';
  static const _kOnboarding = 'pref_onboarding_done';
  static const _kUserName = 'pref_user_name';

  final AuthService _authService = AuthService();
  StreamSubscription<User?>? _authSubscription;

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = AppLocales.fr;
  bool _soundOn = true;
  bool _vibrationOn = true;
  bool _notificationsOn = true;
  bool _hasCompletedOnboarding = false;
  bool _isAuthenticated = false;
  bool _authReady = false;
  String _userName = '';
  String _userEmail = '';

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get soundOn => _soundOn;
  bool get vibrationOn => _vibrationOn;
  bool get notificationsOn => _notificationsOn;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isAuthenticated => _isAuthenticated;
  bool get authReady => _authReady;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userInitials {
    final parts = _userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty && _userEmail.isNotEmpty) {
      return _userEmail.substring(0, 1).toUpperCase();
    }
    if (parts.isEmpty) return 'SS';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String tr(String key) => Tr.of(key, _locale);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = (prefs.getString(_kTheme) ?? 'light') == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
    _locale = Locale(prefs.getString(_kLocale) ?? 'fr');
    _soundOn = prefs.getBool(_kSound) ?? true;
    _vibrationOn = prefs.getBool(_kVibration) ?? true;
    _notificationsOn = prefs.getBool(_kNotifications) ?? true;
    _hasCompletedOnboarding = prefs.getBool(_kOnboarding) ?? false;

    _syncUser(_authService.currentUser, fallbackName: prefs.getString(_kUserName));
    _authReady = true;

    _authSubscription = _authService.authStateChanges.listen((user) {
      _syncUser(user);
      notifyListeners();
    });

    notifyListeners();
  }

  void _syncUser(User? user, {String? fallbackName}) {
    _isAuthenticated = user != null;
    if (user == null) {
      _userName = '';
      _userEmail = '';
      return;
    }

    _userEmail = user.email ?? '';
    _userName = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : (fallbackName ?? '').trim();

    if (_userName.isEmpty && _userEmail.isNotEmpty) {
      _userName = _userEmail.split('@').first;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> toggleTheme() async {
    await setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, locale.languageCode);
  }

  Future<void> setSoundOn(bool value) async {
    _soundOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSound, value);
  }

  Future<void> setVibrationOn(bool value) async {
    _vibrationOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVibration, value);
  }

  Future<void> setNotificationsOn(bool value) async {
    _notificationsOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarding, true);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      _syncUser(credential.user, fallbackName: name.trim());
      _hasCompletedOnboarding = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserName, _userName);
      await prefs.setBool(_kOnboarding, true);
    } catch (error) {
      throw AuthUiException(AuthService.friendlyMessage(error));
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );

      _syncUser(credential.user);
      notifyListeners();
      return true;
    } catch (error) {
      throw AuthUiException(AuthService.friendlyMessage(error));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
    } catch (error) {
      throw AuthUiException(AuthService.friendlyMessage(error));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _syncUser(null);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      await _authService.updateDisplayName(name);
      _userName = name.trim();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserName, _userName);
    } catch (error) {
      throw AuthUiException(AuthService.friendlyMessage(error));
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

class AuthUiException implements Exception {
  const AuthUiException(this.message);

  final String message;

  @override
  String toString() => message;
}

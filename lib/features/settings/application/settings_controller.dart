import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.notificationsEnabled = false,
    this.themeMode = ThemeMode.system,
    this.scheduledCount = 0,
  });

  final bool notificationsEnabled;

  final ThemeMode themeMode;

  /// 현재 예약된 알림 건수. 설정 화면에서 "정말 걸려 있는지" 보여주기 위한 값.
  final int scheduledCount;

  AppSettings copyWith({
    bool? notificationsEnabled,
    ThemeMode? themeMode,
    int? scheduledCount,
  }) => AppSettings(
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    themeMode: themeMode ?? this.themeMode,
    scheduledCount: scheduledCount ?? this.scheduledCount,
  );
}

class SettingsController extends Notifier<AppSettings> {
  static const _kNotifications = 'notifications_enabled';
  static const _kThemeMode = 'theme_mode';

  SharedPreferences? _prefs;

  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    final prefs = _prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      notificationsEnabled: prefs.getBool(_kNotifications) ?? false,
      themeMode: switch (prefs.getString(_kThemeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      scheduledCount: state.scheduledCount,
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _prefs?.setBool(_kNotifications, value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs?.setString(_kThemeMode, mode.name);
  }

  void setScheduledCount(int count) =>
      state = state.copyWith(scheduledCount: count);
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

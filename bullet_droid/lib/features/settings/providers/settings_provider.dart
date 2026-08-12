import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:bullet_droid/shared/providers/hive_provider.dart';

// Provider for settings management
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  final settingsBox = ref.watch(settingsBoxProvider);
  return SettingsNotifier(settingsBox);
});

// Settings model
class AppSettings {
  final int defaultThreads;
  final int defaultTimeout;
  final bool autoSaveResults;
  final int proxyRetryCount;
  final bool enableNotifications;
  final bool enableProxyMaintenance;
  final bool enableLiveHitPush;

  AppSettings({
    this.defaultThreads = 1,
    this.defaultTimeout = 60,
    this.autoSaveResults = true,
    this.proxyRetryCount = 3,
    this.enableNotifications = true,
    this.enableProxyMaintenance = false,
    this.enableLiveHitPush = false,
  });

  AppSettings copyWith({
    int? defaultThreads,
    int? defaultTimeout,
    bool? autoSaveResults,
    int? proxyRetryCount,
    bool? enableNotifications,
    bool? enableProxyMaintenance,
    bool? enableLiveHitPush,
  }) {
    return AppSettings(
      defaultThreads: defaultThreads ?? this.defaultThreads,
      defaultTimeout: defaultTimeout ?? this.defaultTimeout,
      autoSaveResults: autoSaveResults ?? this.autoSaveResults,
      proxyRetryCount: proxyRetryCount ?? this.proxyRetryCount,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableProxyMaintenance: enableProxyMaintenance ?? this.enableProxyMaintenance,
      enableLiveHitPush: enableLiveHitPush ?? this.enableLiveHitPush,
    );
  }

  factory AppSettings.fromBox(Box box) {
    return AppSettings(
      defaultThreads: box.get(SettingsKeys.defaultThreads, defaultValue: 1),
      defaultTimeout: box.get(SettingsKeys.defaultTimeout, defaultValue: 60),
      autoSaveResults: box.get(
        SettingsKeys.autoSaveResults,
        defaultValue: true,
      ),
      proxyRetryCount: box.get(SettingsKeys.proxyRetryCount, defaultValue: 3),
      enableNotifications: box.get(
        SettingsKeys.enableNotifications,
        defaultValue: true,
      ),
      enableProxyMaintenance: box.get(SettingsKeys.enableProxyMaintenance, defaultValue: false),
      enableLiveHitPush: box.get(SettingsKeys.enableLiveHitPush, defaultValue: false),
    );
  }
}

// Settings notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  final Box _settingsBox;

  SettingsNotifier(this._settingsBox)
    : super(AppSettings.fromBox(_settingsBox));

  void setDefaultThreads(int threads) {
    _settingsBox.put(SettingsKeys.defaultThreads, threads);
    state = state.copyWith(defaultThreads: threads);
  }

  void setDefaultTimeout(int timeout) {
    _settingsBox.put(SettingsKeys.defaultTimeout, timeout);
    state = state.copyWith(defaultTimeout: timeout);
  }

  void setAutoSaveResults(bool autoSave) {
    _settingsBox.put(SettingsKeys.autoSaveResults, autoSave);
    state = state.copyWith(autoSaveResults: autoSave);
  }

  void setProxyRetryCount(int retryCount) {
    _settingsBox.put(SettingsKeys.proxyRetryCount, retryCount);
    state = state.copyWith(proxyRetryCount: retryCount);
  }

  void setEnableNotifications(bool enable) {
    _settingsBox.put(SettingsKeys.enableNotifications, enable);
    state = state.copyWith(enableNotifications: enable);
  }

  void setEnableProxyMaintenance(bool enable) {
    _settingsBox.put(SettingsKeys.enableProxyMaintenance, enable);
    state = state.copyWith(enableProxyMaintenance: enable);
  }

  void setEnableLiveHitPush(bool enable) {
    _settingsBox.put(SettingsKeys.enableLiveHitPush, enable);
    state = state.copyWith(enableLiveHitPush: enable);
  }

  void resetToDefaults() {
    _settingsBox.clear();
    state = AppSettings();

    // Save default values
    _settingsBox.put(SettingsKeys.defaultThreads, state.defaultThreads);
    _settingsBox.put(SettingsKeys.defaultTimeout, state.defaultTimeout);
    _settingsBox.put(SettingsKeys.autoSaveResults, state.autoSaveResults);
    _settingsBox.put(SettingsKeys.proxyRetryCount, state.proxyRetryCount);
    _settingsBox.put(SettingsKeys.enableNotifications, state.enableNotifications);
    _settingsBox.put(SettingsKeys.enableProxyMaintenance, state.enableProxyMaintenance);
    _settingsBox.put(SettingsKeys.enableLiveHitPush, state.enableLiveHitPush);
  }
}

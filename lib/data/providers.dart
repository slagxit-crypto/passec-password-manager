import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/security.dart';
import 'database.dart';

// Provide Database Instance
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Provide Security Service Instance
final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService.instance;
});

// Enums for App State
enum AppLockState {
  needsSetup, // First-time setup required
  locked,     // App is locked, authentication required
  unlocked,   // App is unlocked
}

// App Lock State Notifier
class AppLockNotifier extends StateNotifier<AppLockState> {
  final SecurityService _securityService;

  AppLockNotifier(this._securityService) : super(AppLockState.locked) {
    checkSetupStatus();
  }

  Future<void> checkSetupStatus() async {
    final hasKey = await _securityService.hasMasterKey();
    if (!hasKey) {
      state = AppLockState.needsSetup;
    } else {
      state = AppLockState.locked;
    }
  }

  Future<bool> setupPIN(String pin) async {
    final key = _securityService.generateRandomBytes(32);
    await _securityService.saveMasterKey(key, pin: pin);
    await _securityService.unlockWithStorage(pin: pin);
    state = AppLockState.unlocked;
    return true;
  }

  Future<bool> setupBiometrics() async {
    final key = _securityService.generateRandomBytes(32);
    await _securityService.saveMasterKey(key);
    await _securityService.unlockWithStorage();
    state = AppLockState.unlocked;
    return true;
  }

  Future<bool> unlockWithPIN(String pin) async {
    final success = await _securityService.unlockWithStorage(pin: pin);
    if (success) {
      state = AppLockState.unlocked;
      return true;
    }
    return false;
  }

  Future<bool> unlockWithBiometrics() async {
    final authenticated = await _securityService.authenticateUser();
    if (authenticated) {
      final success = await _securityService.unlockWithStorage();
      if (success) {
        state = AppLockState.unlocked;
        return true;
      }
    }
    return false;
  }

  void lock() {
    _securityService.lock();
    state = AppLockState.locked;
  }

  Future<void> factoryReset() async {
    try {
      await _securityService.clearAllSecureData();
    } catch (_) {}
    state = AppLockState.needsSetup;
  }
}

final appLockProvider = StateNotifierProvider<AppLockNotifier, AppLockState>((ref) {
  final security = ref.watch(securityServiceProvider);
  return AppLockNotifier(security);
});

// Theme Mode Provider (Dark Mode by Default)
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? true;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await prefs.setBool('is_dark_mode', false);
    } else {
      state = ThemeMode.dark;
      await prefs.setBool('is_dark_mode', true);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Auto Lock Timeout Provider (Default is 5 minutes)
class AutoLockNotifier extends StateNotifier<Duration> {
  AutoLockNotifier() : super(const Duration(minutes: 5)) {
    _loadInterval();
  }

  Future<void> _loadInterval() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('auto_lock_minutes') ?? 5;
    state = Duration(minutes: minutes);
  }

  Future<void> setInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    state = Duration(minutes: minutes);
    await prefs.setInt('auto_lock_minutes', minutes);
  }
}

final autoLockProvider = StateNotifierProvider<AutoLockNotifier, Duration>((ref) {
  return AutoLockNotifier();
});

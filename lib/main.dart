import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'data/providers.dart';
import 'features/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PassecApp(),
    ),
  );
}

class PassecApp extends ConsumerStatefulWidget {
  const PassecApp({super.key});

  @override
  ConsumerState<PassecApp> createState() => _PassecAppState();
}

class _PassecAppState extends ConsumerState<PassecApp> with WidgetsBindingObserver {
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pausedTime ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedTime != null) {
        final autoLockDuration = ref.read(autoLockProvider);
        final elapsed = DateTime.now().difference(_pausedTime!);
        if (elapsed >= autoLockDuration) {
          ref.read(appLockProvider.notifier).lock();
        }
        _pausedTime = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF6C63FF),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: const Color(0xFF6C63FF),
      scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF4CAF50),
        surface: Color(0xFF13132A),
        onSurface: Colors.white,
        onPrimary: Colors.white,
        tertiary: Color(0xFFFFC107),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D0D1A),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF13132A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A4A), width: 1),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Color(0xFFAAAAAA)),
        labelSmall: TextStyle(color: Color(0xFF888888)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A30),
        hintStyle: const TextStyle(color: Color(0xFF555580)),
        labelStyle: const TextStyle(color: Color(0xFF8888AA)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        prefixIconColor: const Color(0xFF6C63FF),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF6C63FF),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1A1A30),
        selectedColor: const Color(0xFF6C63FF),
        labelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: Color(0xFF2A2A4A)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2A2A4A)),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFF6C63FF),
        textColor: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF13132A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF13132A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF1A1A30),
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? const Color(0xFF6C63FF) : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? const Color(0xFF6C63FF).withOpacity(0.4) : Colors.grey.shade800),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF6C63FF)),
    );

    return MaterialApp(
      title: 'PASSEC',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode, // Use the user's selected theme
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const LifecycleManager(
        child: AppLockRouter(),
      ),
    );
  }
}


// Lifecycle Observer to handle Auto-Locking
class LifecycleManager extends ConsumerStatefulWidget {
  final Widget child;
  const LifecycleManager({super.key, required this.child});

  @override
  ConsumerState<LifecycleManager> createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends ConsumerState<LifecycleManager>
    with WidgetsBindingObserver {
  DateTime? _backgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final lockState = ref.read(appLockProvider);
    if (lockState != AppLockState.unlocked) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      _backgroundTime ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        final elapsed = DateTime.now().difference(_backgroundTime!);
        final lockTimeout = ref.read(autoLockProvider);
        if (elapsed >= lockTimeout) {
          ref.read(appLockProvider.notifier).lock();
        }
      }
      _backgroundTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Router to decide showing Lock screen, Setup screen, or Main Space screen
class AppLockRouter extends ConsumerWidget {
  const AppLockRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(appLockProvider);

    switch (lockState) {
      case AppLockState.needsSetup:
        return const SetupScreen();
      case AppLockState.locked:
        return const LockScreen();
      case AppLockState.unlocked:
        return const HomeScreen();
    }
  }
}

// ---------------- SETUP SCREEN ----------------
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _useBiometrics = true;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_pinController.text != _confirmPinController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PINs do not match')),
        );
        return;
      }
      try {
        await ref.read(appLockProvider.notifier).setupPIN(_pinController.text);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Hero(
                tag: 'logo',
                child: Icon(Icons.security, size: 80, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(height: 16),
              Text(
                'PASSEC',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Secure Offline Password Vault',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _pinController,
                      decoration: InputDecoration(
                        labelText: 'Create 6-digit PIN',
                        hintText: 'xxxxxx',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'PIN must be exactly 6 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPinController,
                      decoration: InputDecoration(
                        labelText: 'Confirm PIN',
                        hintText: 'xxxxxx',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.check_circle_outline),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your PIN';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Setup Secure Vault', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
              // Biometrics check
              FutureBuilder<bool>(
                future: ref.read(securityServiceProvider).isBiometricsSupported(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fingerprint, color: Color(0xFF0EA5E9)),
                        const SizedBox(width: 8),
                        const Text('Enable Device Biometrics'),
                        Switch(
                          value: _useBiometrics,
                          onChanged: (val) {
                            setState(() {
                              _useBiometrics = val;
                            });
                          },
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- LOCK SCREEN ----------------
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();
  bool _showPinInput = false;
  String _errorMessage = '';
  int _failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    // Auto-prompt biometrics on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricUnlock();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricUnlock() async {
    setState(() {
      _errorMessage = '';
    });
    final success = await ref.read(appLockProvider.notifier).unlockWithBiometrics();
    if (!success) {
      setState(() {
        _showPinInput = true;
      });
    }
  }

  Future<void> _submitPin() async {
    final success = await ref.read(appLockProvider.notifier).unlockWithPIN(_pinController.text);
    if (success) {
      _pinController.clear();
      setState(() {
        _failedAttempts = 0;
      });
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Please try again.';
        _pinController.clear();
        _failedAttempts++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Hero(
                tag: 'logo',
                child: Icon(Icons.security, size: 80, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(height: 16),
              Text(
                'PASSEC',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vault is Locked',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              if (!_showPinInput) ...[
                IconButton(
                  icon: const Icon(Icons.fingerprint, size: 72, color: Color(0xFF3B82F6)),
                  onPressed: _tryBiometricUnlock,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showPinInput = true;
                    });
                  },
                  child: const Text('Unlock with PIN'),
                ),
              ] else ...[
                TextField(
                  controller: _pinController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Enter 6-digit PIN',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: _errorMessage.isEmpty ? null : _errorMessage,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  onChanged: (val) {
                    if (val.length == 6) {
                      _submitPin();
                    }
                  },
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showPinInput = false;
                    });
                    _tryBiometricUnlock();
                  },
                  child: const Text('Use Biometrics'),
                ),
              ],
              if (_failedAttempts > 0) ...[
                const SizedBox(height: 48),
                TextButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Factory Reset?'),
                        content: const Text('This will delete all your vaults and accounts. This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                await ref.read(appLockProvider.notifier).factoryReset();
                              } catch (e) {
                                debugPrint('Factory reset failed: $e');
                              }
                              try {
                                await ref.read(databaseProvider).clearDatabase();
                              } catch (e) {
                                debugPrint('Database clear failed: $e');
                              }
                            },
                            child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  label: const Text('Reset App Data', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

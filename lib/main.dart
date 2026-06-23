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

class PassecApp extends ConsumerWidget {
  const PassecApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'PASSEC',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      // Minimal Premium Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF0EA5E9),
          surface: Colors.white,
          onSurface: Color(0xFF0F172A),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          bodyMedium: TextStyle(color: Color(0xFF475569)),
        ),
        useMaterial3: true,
      ),
      // Sleek Cyber Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF151D30),
          onSurface: Colors.white,
          background: Color(0xFF0A0F1D),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF151D30).withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0)),
          bodyMedium: TextStyle(color: Color(0xFF94A3B8)),
        ),
        useMaterial3: true,
      ),
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

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _backgroundTime = DateTime.now();
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
      await ref.read(appLockProvider.notifier).setupPIN(_pinController.text);
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
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Please try again.';
        _pinController.clear();
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
            ],
          ),
        ),
      ),
    );
  }
}

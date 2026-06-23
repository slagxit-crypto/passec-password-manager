import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

Future<bool> showAuthDialog(BuildContext context, WidgetRef ref) async {
  final security = ref.read(securityServiceProvider);
  
  // Try biometric/device auth first
  final authenticated = await security.authenticateUser();
  if (authenticated) return true;

  // Fallback to custom PIN dialog if biometrics failed or aren't supported
  if (!context.mounted) return false;
  
  bool success = false;
  final controller = TextEditingController();
  
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Authentication Required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please enter your 6-digit app PIN to continue.'),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '******',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () async {
            final isValid = await ref.read(appLockProvider.notifier).unlockWithPIN(controller.text);
            if (isValid) {
              success = true;
              if (context.mounted) Navigator.pop(context);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect PIN', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
                );
              }
            }
          },
          child: const Text('Verify'),
        ),
      ],
    ),
  );
  
  return success;
}

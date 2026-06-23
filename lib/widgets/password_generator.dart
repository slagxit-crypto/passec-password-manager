import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/security.dart';

class PasswordGeneratorWidget extends StatefulWidget {
  final ValueChanged<String> onPasswordGenerated;

  const PasswordGeneratorWidget({super.key, required this.onPasswordGenerated});

  @override
  State<PasswordGeneratorWidget> createState() => _PasswordGeneratorWidgetState();
}

class _PasswordGeneratorWidgetState extends State<PasswordGeneratorWidget> {
  int _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    setState(() {
      _generatedPassword = SecurityService.instance.generatePassword(
        length: _length,
        includeUppercase: _includeUppercase,
        includeLowercase: _includeLowercase,
        includeNumbers: _includeNumbers,
        includeSymbols: _includeSymbols,
      );
    });
  }

  String _getPasswordStrength() {
    if (_generatedPassword.isEmpty) return 'None';
    int score = 0;
    if (_generatedPassword.length >= 12) score++;
    if (_generatedPassword.length >= 16) score++;
    if (_includeUppercase) score++;
    if (_includeLowercase) score++;
    if (_includeNumbers) score++;
    if (_includeSymbols) score++;

    if (score <= 2) return 'Weak';
    if (score <= 4) return 'Medium';
    if (score <= 5) return 'Strong';
    return 'Very Strong';
  }

  Color _getStrengthColor() {
    final strength = _getPasswordStrength();
    switch (strength) {
      case 'Weak':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      case 'Strong':
        return Colors.greenAccent;
      case 'Very Strong':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getPasswordStrength();
    final strengthColor = _getStrengthColor();

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Generate Password',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Generated password display card
            Card(
              color: Theme.of(context).cardTheme.color,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _generatedPassword,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'JetBrainsMono',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Color(0xFF3B82F6)),
                          onPressed: _generate,
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _generatedPassword));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password copied')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Strength:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: strengthColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            strength,
                            style: TextStyle(fontSize: 12, color: strengthColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Length Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Password Length', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '$_length',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                ),
              ],
            ),
            Slider(
              value: _length.toDouble(),
              min: 8,
              max: 64,
              divisions: 56,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (val) {
                setState(() {
                  _length = val.round();
                  _generate();
                });
              },
            ),
            const SizedBox(height: 8),

            // Settings switches
            CheckboxListTile(
              title: const Text('Uppercase Letters (A-Z)'),
              value: _includeUppercase,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) {
                setState(() {
                  _includeUppercase = val ?? true;
                  _generate();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Lowercase Letters (a-z)'),
              value: _includeLowercase,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) {
                setState(() {
                  _includeLowercase = val ?? true;
                  _generate();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Numbers (0-9)'),
              value: _includeNumbers,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) {
                setState(() {
                  _includeNumbers = val ?? true;
                  _generate();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Symbols (!@#\$%^&*)'),
              value: _includeSymbols,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) {
                setState(() {
                  _includeSymbols = val ?? true;
                  _generate();
                });
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                widget.onPasswordGenerated(_generatedPassword);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Use Generated Password', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

void showPasswordGeneratorBottomSheet(BuildContext context, ValueChanged<String> onPasswordGenerated) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => PasswordGeneratorWidget(onPasswordGenerated: onPasswordGenerated),
  );
}

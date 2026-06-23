import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../widgets/auth_dialog.dart';
import '../../widgets/password_generator.dart';

class AccountScreen extends ConsumerStatefulWidget {
  final String spaceId;
  final Account? account; // Null if creating a new account

  const AccountScreen({
    super.key,
    required this.spaceId,
    this.account,
  });

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();
  final _recoveryEmailController = TextEditingController();
  final _recoveryPhoneController = TextEditingController();
  final _websiteUrlController = TextEditingController();

  bool _isEditing = false;
  bool _isPasswordRevealed = false;
  String _decryptedPassword = '';

  // Timers for security tasks
  Timer? _revealTimer;
  Timer? _clipboardTimer;
  int _revealCountdown = 15;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      // View mode
      _isEditing = false;
      _nameController.text = widget.account!.accountName;
      _usernameController.text = widget.account!.username;
      _notesController.text = widget.account!.notes ?? '';
      _recoveryEmailController.text = widget.account!.recoveryEmail ?? '';
      _recoveryPhoneController.text = widget.account!.recoveryPhoneNumber ?? '';
      _websiteUrlController.text = widget.account!.websiteUrl ?? '';
      
      // Decrypt password only on-demand
      _passwordController.text = widget.account!.encryptedPassword;
    } else {
      // Create mode
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _clipboardTimer?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    _recoveryEmailController.dispose();
    _recoveryPhoneController.dispose();
    _websiteUrlController.dispose();
    super.dispose();
  }

  // Decrypts password using security service
  String getDecryptedPassword() {
    if (_decryptedPassword.isNotEmpty) return _decryptedPassword;
    try {
      final security = ref.read(securityServiceProvider);
      _decryptedPassword = security.decryptString(widget.account!.encryptedPassword);
      return _decryptedPassword;
    } catch (_) {
      return 'Decryption Error';
    }
  }

  // Reveals password temporarily with 15s countdown
  Future<void> _revealPassword() async {
    if (_isPasswordRevealed) {
      setState(() {
        _isPasswordRevealed = false;
        _revealTimer?.cancel();
      });
      return;
    }

    // Require local authentication to reveal
    final authenticated = await showAuthDialog(context, ref);
    if (!authenticated) return;

    setState(() {
      _isPasswordRevealed = true;
      _revealCountdown = 15;
    });

    _revealTimer?.cancel();
    _revealTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_revealCountdown > 1) {
        setState(() {
          _revealCountdown--;
        });
      } else {
        setState(() {
          _isPasswordRevealed = false;
        });
        timer.cancel();
      }
    });

    // Update database last accessed field
    if (widget.account != null) {
      ref.read(databaseProvider).updateLastAccessed(widget.account!.id);
    }
  }

  // Copies password with 30s clipboard clearing
  Future<void> _copyPassword() async {
    final passwordToCopy = widget.account != null
        ? getDecryptedPassword()
        : _passwordController.text;

    if (passwordToCopy.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: passwordToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password copied. Clipboard will clear in 30 seconds.'),
        duration: Duration(seconds: 4),
      ),
    );

    _clipboardTimer?.cancel();
    _clipboardTimer = Timer(const Duration(seconds: 30), () async {
      final currentClipboard = await Clipboard.getData(Clipboard.kTextPlain);
      if (currentClipboard?.text == passwordToCopy) {
        await Clipboard.setData(const ClipboardData(text: ''));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clipboard cleared for security.')),
          );
        }
      }
    });

    // Update database last accessed field
    if (widget.account != null) {
      ref.read(databaseProvider).updateLastAccessed(widget.account!.id);
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(databaseProvider);
    final security = ref.read(securityServiceProvider);

    final rawPassword = _passwordController.text;
    final encryptedPassword = security.encryptString(rawPassword);

    if (widget.account == null) {
      // New Account
      final newId = const Uuid().v4();
      await db.insertAccount(
        AccountsCompanion.insert(
          id: newId,
          spaceId: widget.spaceId,
          accountName: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          encryptedPassword: encryptedPassword,
          notes: drift.Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
          recoveryEmail: drift.Value(_recoveryEmailController.text.trim().isEmpty ? null : _recoveryEmailController.text.trim()),
          recoveryPhoneNumber: drift.Value(_recoveryPhoneController.text.trim().isEmpty ? null : _recoveryPhoneController.text.trim()),
          websiteUrl: drift.Value(_websiteUrlController.text.trim().isEmpty ? null : _websiteUrlController.text.trim()),
          isFavorite: const drift.Value(false),
          createdAt: drift.Value(DateTime.now()),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created & saved')),
      );
    } else {
      // Update Account
      // Only re-encrypt if password changed, otherwise preserve it
      final newEncryptedPassword = (_passwordController.text != widget.account!.encryptedPassword && _passwordController.text.isNotEmpty)
          ? security.encryptString(_passwordController.text)
          : widget.account!.encryptedPassword;

      await db.updateAccount(
        widget.account!.copyWith(
          accountName: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          encryptedPassword: newEncryptedPassword,
          notes: drift.Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
          recoveryEmail: drift.Value(_recoveryEmailController.text.trim().isEmpty ? null : _recoveryEmailController.text.trim()),
          recoveryPhoneNumber: drift.Value(_recoveryPhoneController.text.trim().isEmpty ? null : _recoveryPhoneController.text.trim()),
          websiteUrl: drift.Value(_websiteUrlController.text.trim().isEmpty ? null : _websiteUrlController.text.trim()),
          updatedAt: DateTime.now(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
    }

    Navigator.pop(context);
  }

  Future<void> _deleteAccount() async {
    // Sensitive operation: Authenticate first
    final authenticated = await showAuthDialog(context, ref);
    if (!authenticated) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: Text('Are you sure you want to permanently delete "${_nameController.text}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (widget.account != null) {
                final db = ref.read(databaseProvider);
                await db.deleteAccount(widget.account!.id);
              }
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.account == null
        ? 'New Account'
        : (_isEditing ? 'Edit Account' : 'Account Details');

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (widget.account != null) ...[
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                    // Pre-fill password controller with plain text during edit
                    _passwordController.text = getDecryptedPassword();
                  });
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _passwordController.text = widget.account!.encryptedPassword;
                    _decryptedPassword = '';
                  });
                },
              ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------- READ-ONLY VIEW ----------------
              if (!_isEditing && widget.account != null) ...[
                _buildReadOnlyField('Account Name', _nameController.text, Icons.label_outline),
                _buildReadOnlyField('Username / Email', _usernameController.text, Icons.person_outline, copyable: true),
                
                // Password Field Card with View/Copy Actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Password', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _isPasswordRevealed ? getDecryptedPassword() : '••••••••••••••••',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: _isPasswordRevealed ? 'JetBrainsMono' : null,
                                  letterSpacing: _isPasswordRevealed ? 1.0 : 2.5,
                                ),
                              ),
                            ),
                            // Countdown badge if revealed
                            if (_isPasswordRevealed)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$_revealCountdown',
                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            IconButton(
                              icon: Icon(_isPasswordRevealed ? Icons.visibility_off : Icons.visibility),
                              onPressed: _revealPassword,
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: _copyPassword,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (_websiteUrlController.text.isNotEmpty)
                  _buildReadOnlyField('Website', _websiteUrlController.text, Icons.link_outlined, copyable: true),
                if (_recoveryEmailController.text.isNotEmpty)
                  _buildReadOnlyField('Recovery Email', _recoveryEmailController.text, Icons.mail_outline, copyable: true),
                if (_recoveryPhoneController.text.isNotEmpty)
                  _buildReadOnlyField('Recovery Phone', _recoveryPhoneController.text, Icons.phone_android_outlined, copyable: true),
                if (_notesController.text.isNotEmpty)
                  _buildReadOnlyField('Notes', _notesController.text, Icons.notes_outlined, maxLines: 5),

                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _deleteAccount,
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Delete Account', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ]
              // ---------------- EDITING / CREATING FORM ----------------
              else ...[
                // Account Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name *',
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Account Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username / Email Input
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username / Email / Mobile *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Username/Email is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Input + Generator Integration
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.vpn_key, color: Color(0xFF3B82F6)),
                          onPressed: () {
                            showPasswordGeneratorBottomSheet(context, (generated) {
                              _passwordController.text = generated;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Website URL
                TextFormField(
                  controller: _websiteUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Website URL (Optional)',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),

                // Recovery Email
                TextFormField(
                  controller: _recoveryEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Recovery Email (Optional)',
                    prefixIcon: Icon(Icons.mail),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Recovery Phone
                TextFormField(
                  controller: _recoveryPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Recovery Phone (Optional)',
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Save and Cancel Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (widget.account == null) {
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              _isEditing = false;
                              _passwordController.text = widget.account!.encryptedPassword;
                            });
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Details'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon, {bool copyable = false, int maxLines = 1}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (copyable)
              IconButton(
                icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label copied to clipboard')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

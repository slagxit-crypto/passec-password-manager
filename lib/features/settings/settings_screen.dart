import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../widgets/auth_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import '../../core/backup_service.dart';
import 'web_helper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _passwordController = TextEditingController();
  final _resetConfirmationController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _resetConfirmationController.dispose();
    super.dispose();
  }

  // --- Theme Toggle ---
  void _toggleTheme() {
    ref.read(themeProvider.notifier).toggleTheme();
  }

  // --- Auto Lock Selection ---
  void _changeAutoLock(int minutes) {
    ref.read(autoLockProvider.notifier).setInterval(minutes);
  }

  // --- Export Backup Dialog ---
  Future<void> _exportBackupFlow() async {
    final db = ref.read(databaseProvider);
    final spaces = await db.getAllSpaces();

    if (spaces.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No spaces available to export.')),
        );
      }
      return;
    }

    final selectedSpaceIds = spaces.map((s) => s.id).toList();
    _passwordController.clear();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Export Spaces'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select spaces to include in the backup file:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      // --- ABOUT SECTION ---
                      Text(
                        'ABOUT',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.info_outline),
                              title: const Text('About PASSEC'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const AboutDialog(
                                    applicationName: 'PASSEC',
                                    applicationVersion: '1.0.0',
                                    applicationIcon: Icon(Icons.security, size: 64, color: Color(0xFF3B82F6)),
                                    children: [
                                      SizedBox(height: 16),
                                      Text(
                                        'PASSEC is an application made to manage your passwords locally. It is a minimal, clean, lightweight, and privacy-focused password manager that securely encrypts all data completely offline using AES-256-CBC encryption.',
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'This application is completely made by vibe coding by Saint Soori using tools such as: ChatGPT, Antigravity, Claude, and Gemini.',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                      SizedBox(height: 16),
                                      Text('Author: Saint Soori', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- DANGER ZONE ---
                      ...spaces.map((s) {
                        final isChecked = selectedSpaceIds.contains(s.id);
                        return CheckboxListTile(
                          title: Text(s.name),
                          value: isChecked,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                selectedSpaceIds.add(s.id);
                              } else {
                                selectedSpaceIds.remove(s.id);
                              }
                            });
                          },
                        );
                      }),
                      const Divider(),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Backup Password',
                          hintText: 'Enter password to encrypt file',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedSpaceIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one space')),
                      );
                      return;
                    }
                    if (_passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password is required to encrypt backup')),
                      );
                      return;
                    }

                    final password = _passwordController.text;
                    Navigator.pop(context); // Close dialog

                    try {
                      final backupData = await BackupService.instance.exportBackup(
                        spaceIds: selectedSpaceIds,
                        password: password,
                        db: db,
                      );

                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Backup Created'),
                            content: const Text('Your encrypted backup was created successfully. How would you like to save it?'),
                            actions: [
                              TextButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: backupData));
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Backup code copied to clipboard')),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('Copy Code'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  if (kIsWeb) {
                                    downloadFileWeb('passec_backup.passec', backupData);
                                  } else {
                                    // Use Share sheet to save to file manager securely
                                    final directory = await getTemporaryDirectory();
                                    final path = p.join(directory.path, 'passec_backup.passec');
                                    final file = File(path);
                                    await file.writeAsString(backupData);
                                    await Share.shareXFiles([XFile(path)], text: 'My PASSEC Backup');
                                  }
                                },
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text('Download File'),
                              ),
                            ],
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Export'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Import Backup Dialog ---
  Future<void> _importBackupFlow() async {
    _passwordController.clear();
    final backupCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import Backup'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (kIsWeb) {
                        uploadFileWeb((fileContent) {
                          _promptForImportPassword(fileContent);
                        });
                      } else {
                        final result = await FilePicker.platform.pickFiles(type: FileType.any);
                        if (result != null && result.files.single.path != null) {
                          try {
                            final file = File(result.files.single.path!);
                            final fileContent = await file.readAsString();
                            _promptForImportPassword(fileContent);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error reading file. Please paste code instead.')),
                              );
                            }
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Choose .passec File'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('OR paste backup code below:'),
                  ),
                TextField(
                  controller: backupCodeController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Paste Backup Code',
                    hintText: 'Paste raw .passec file content here',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Backup Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (backupCodeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please paste the backup code')),
                  );
                  return;
                }
                if (_passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter backup encryption password')),
                  );
                  return;
                }

                final backupCode = backupCodeController.text.trim();
                final password = _passwordController.text;
                Navigator.pop(context); // Close dialog

                await _processImport(backupCode, password);
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }

  void _promptForImportPassword(String fileContent) {
    _passwordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Backup Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final password = _passwordController.text;
              Navigator.pop(context);
              await _processImport(fileContent, password);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _processImport(String content, String password) async {
    final db = ref.read(databaseProvider);
    final success = await BackupService.instance.importBackup(
      backupContent: content,
      password: password,
      db: db,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vault data restored successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Import failed. Invalid password or corrupted file.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // --- Factory Reset ---
  Future<void> _factoryResetFlow() async {
    // 1. Authenticate user biometrics/PIN first
    final authenticated = await showAuthDialog(context, ref);
    if (!authenticated) return;

    _resetConfirmationController.clear();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Factory Reset', style: TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WARNING: This will permanently delete all spaces, accounts, and cryptographic keys. This action CANNOT be undone.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Please type "RESET" to confirm:'),
            const SizedBox(height: 8),
            TextField(
              controller: _resetConfirmationController,
              decoration: const InputDecoration(
                hintText: 'RESET',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_resetConfirmationController.text.trim() == 'RESET') {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Exit settings

                // Clear everything
                await ref.read(appLockProvider.notifier).factoryReset();
                await ref.read(databaseProvider).clearDatabase();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vault has been reset to factory settings.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Confirmation text incorrect. Reset cancelled.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete Everything', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final autoLock = ref.watch(autoLockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          Card(
            child: ListTile(
              leading: Icon(
                theme == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                color: const Color(0xFF3B82F6),
              ),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: theme == ThemeMode.dark,
                onChanged: (_) => _toggleTheme(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Security Section
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.timer_outlined, color: Color(0xFF3B82F6)),
                    title: Text('Auto Lock Timer'),
                    subtitle: Text('Lock the vault when application is backgrounded'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ChoiceChip(
                          label: const Text('1 min'),
                          selected: autoLock.inMinutes == 1,
                          onSelected: (val) => _changeAutoLock(1),
                        ),
                        ChoiceChip(
                          label: const Text('5 mins'),
                          selected: autoLock.inMinutes == 5,
                          onSelected: (val) => _changeAutoLock(5),
                        ),
                        ChoiceChip(
                          label: const Text('15 mins'),
                          selected: autoLock.inMinutes == 15,
                          onSelected: (val) => _changeAutoLock(15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // About Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
              title: const Text('About PASSEC'),
              subtitle: const Text('App info & developer credits'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AboutDialog(
                    applicationName: 'PASSEC',
                    applicationVersion: '1.0.0',
                    applicationIcon: Icon(Icons.security, size: 64, color: Color(0xFF3B82F6)),
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'PASSEC is an application made to manage your passwords locally. It is a minimal, clean, lightweight, and privacy-focused password manager that securely encrypts all data completely offline using AES-256-CBC encryption.',
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This application is completely made by vibe coding by Saint Soori using tools such as: ChatGPT, Antigravity, Claude, and Gemini.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 16),
                      Text('Author: Saint Soori', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Backup Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download, color: Color(0xFF3B82F6)),
                  title: const Text('Export Backup (.passec)'),
                  subtitle: const Text('Save encrypted space data to a container file'),
                  onTap: _exportBackupFlow,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.upload, color: Color(0xFF3B82F6)),
                  title: const Text('Import Backup (.passec)'),
                  subtitle: const Text('Restore spaces and accounts from container'),
                  onTap: _importBackupFlow,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Factory Reset Section
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text('Factory Reset', style: TextStyle(color: Colors.redAccent)),
              subtitle: const Text('Permanently clear all local vault data'),
              onTap: _factoryResetFlow,
            ),
          ),
        ],
      ),
    );
  }
}

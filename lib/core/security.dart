import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  SecurityService._privateConstructor();
  static final SecurityService instance = SecurityService._privateConstructor();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final _localAuth = LocalAuthentication();

  // In-memory decrypted Master Key (256-bit)
  Uint8List? _masterKey;

  bool get isLocked => _masterKey == null;

  /// Generate a cryptographically secure random key of [length] bytes.
  Uint8List generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }

  /// Lock the application by wiping the master key from memory.
  void lock() {
    _masterKey = null;
  }

  /// Check if the device supports any biometric authentication or device locks.
  Future<bool> isBiometricsSupported() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Authenticate user via Device Biometrics or PIN/Password (Fallback).
  Future<bool> authenticateUser() async {
    try {
      final isSupported = await isBiometricsSupported();
      if (!isSupported) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access PASSEC',
        options: const AuthenticationOptions(
          biometricOnly: false, // Allows device PIN/Passcode fallback
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Get or initialize the master key using secure storage.
  /// If [pin] is provided, it serves as an extra layer of protection (derived key encrypts master key).
  /// If biometric is used, we can store it directly in keystore or encrypted.
  Future<bool> unlockWithStorage({String? pin}) async {
    try {
      final storedKeyBase64 = await _secureStorage.read(key: 'passec_master_key');
      if (storedKeyBase64 == null) {
        // First run: Generate a new master key
        final newKey = generateRandomBytes(32); // 256-bit
        await saveMasterKey(newKey, pin: pin);
        _masterKey = newKey;
        return true;
      }

      if (pin != null) {
        // Master key is encrypted with PIN
        final encryptedData = jsonDecode(storedKeyBase64);
        final ciphertext = base64Decode(encryptedData['ciphertext'] as String);
        final iv = base64Decode(encryptedData['iv'] as String);
        final salt = base64Decode(encryptedData['salt'] as String);

        final derivedKey = deriveKeyFromPin(pin, salt);
        final decryptedKey = decryptAES(ciphertext, derivedKey, iv);
        if (decryptedKey != null && decryptedKey.length == 32) {
          _masterKey = decryptedKey;
          return true;
        }
        return false; // Wrong PIN
      } else {
        // Direct storage retrieval (rely on Keystore encryption)
        _masterKey = base64Decode(storedKeyBase64);
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  /// Save the master key to secure storage.
  Future<void> saveMasterKey(Uint8List key, {String? pin}) async {
    if (pin != null) {
      final salt = generateRandomBytes(16);
      final derivedKey = deriveKeyFromPin(pin, salt);
      final iv = generateRandomBytes(16);
      
      final encryptedBytes = encryptAES(key, derivedKey, iv);
      final payload = {
        'ciphertext': base64Encode(encryptedBytes),
        'iv': base64Encode(iv),
        'salt': base64Encode(salt),
      };
      await _secureStorage.write(key: 'passec_master_key', value: jsonEncode(payload));
      await _secureStorage.write(key: 'auth_mode', value: 'pin');
    } else {
      await _secureStorage.write(key: 'passec_master_key', value: base64Encode(key));
      await _secureStorage.write(key: 'auth_mode', value: 'biometric');
    }
  }

  /// Check if the master key has been initialized.
  Future<bool> hasMasterKey() async {
    return (await _secureStorage.read(key: 'passec_master_key')) != null;
  }

  /// Clear all stored credentials and database (Factory Reset).
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
    _masterKey = null;
  }

  /// Derive a 256-bit key from a user PIN using PBKDF2-HMAC-SHA256.
  Uint8List deriveKeyFromPin(String pin, Uint8List salt) {
    return pbkdf2(pin, salt, 50000, 32);
  }

  /// Pure Dart PBKDF2 implementation.
  Uint8List pbkdf2(String password, Uint8List salt, int iterations, int keyLength) {
    final hmac = Hmac(sha256, password.codeUnits);
    final key = Uint8List(keyLength);
    int keyOffset = 0;
    int blockIndex = 1;

    while (keyOffset < keyLength) {
      final blockIndexBytes = ByteData(4)..setUint32(0, blockIndex);
      final input = Uint8List(salt.length + 4);
      input.setRange(0, salt.length, salt);
      input.setRange(salt.length, input.length, blockIndexBytes.buffer.asUint8List());

      var u = hmac.convert(input).bytes;
      var xorSum = Uint8List.fromList(u);

      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < xorSum.length; j++) {
          xorSum[j] ^= u[j];
        }
      }

      final bytesToWrite = (keyLength - keyOffset < xorSum.length)
          ? keyLength - keyOffset
          : xorSum.length;
      key.setRange(keyOffset, keyOffset + bytesToWrite, xorSum);
      keyOffset += bytesToWrite;
      blockIndex++;
    }

    return key;
  }

  /// Encrypt sensitive string with a key.
  String encryptString(String plainText) {
    if (_masterKey == null) throw Exception("App is locked");
    final iv = generateRandomBytes(16);
    final plainBytes = utf8.encode(plainText);
    final encryptedBytes = encryptAES(Uint8List.fromList(plainBytes), _masterKey!, iv);
    
    final payload = {
      'ciphertext': base64Encode(encryptedBytes),
      'iv': base64Encode(iv),
    };
    return jsonEncode(payload);
  }

  /// Decrypt sensitive string with the master key.
  String decryptString(String encryptedJson) {
    if (_masterKey == null) throw Exception("App is locked");
    try {
      final data = jsonDecode(encryptedJson);
      final ciphertext = base64Decode(data['ciphertext'] as String);
      final iv = base64Decode(data['iv'] as String);
      
      final decryptedBytes = decryptAES(ciphertext, _masterKey!, iv);
      if (decryptedBytes == null) throw Exception("Decryption failed");
      return utf8.decode(decryptedBytes);
    } catch (_) {
      return "••••••••"; // Fallback text on error
    }
  }

  /// Encrypt bytes with AES-256-CBC.
  Uint8List encryptAES(Uint8List plainBytes, Uint8List keyBytes, Uint8List ivBytes) {
    final key = enc.Key(keyBytes);
    final iv = enc.IV(ivBytes);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return Uint8List.fromList(encrypter.encryptBytes(plainBytes, iv: iv).bytes);
  }

  /// Decrypt bytes with AES-256-CBC.
  Uint8List? decryptAES(Uint8List cipherBytes, Uint8List keyBytes, Uint8List ivBytes) {
    try {
      final key = enc.Key(keyBytes);
      final iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (_) {
      return null;
    }
  }

  /// Password Generator
  String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    const uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const numberChars = '0123456789';
    const symbolChars = '!@#\$%^&*()_-+=<>?/[]{}|';

    String allowedChars = '';
    List<String> guaranteedChars = [];
    final rand = Random.secure();

    if (includeUppercase) {
      allowedChars += uppercaseChars;
      guaranteedChars.add(uppercaseChars[rand.nextInt(uppercaseChars.length)]);
    }
    if (includeLowercase) {
      allowedChars += lowercaseChars;
      guaranteedChars.add(lowercaseChars[rand.nextInt(lowercaseChars.length)]);
    }
    if (includeNumbers) {
      allowedChars += numberChars;
      guaranteedChars.add(numberChars[rand.nextInt(numberChars.length)]);
    }
    if (includeSymbols) {
      allowedChars += symbolChars;
      guaranteedChars.add(symbolChars[rand.nextInt(symbolChars.length)]);
    }

    if (allowedChars.isEmpty) {
      allowedChars = lowercaseChars + numberChars;
    }

    final remainingLength = length - guaranteedChars.length;
    for (int i = 0; i < remainingLength; i++) {
      guaranteedChars.add(allowedChars[rand.nextInt(allowedChars.length)]);
    }

    // Shuffle the character list
    guaranteedChars.shuffle(rand);
    return guaranteedChars.join('');
  }
}

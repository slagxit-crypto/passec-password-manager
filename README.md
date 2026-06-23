# PASSEC (Pass + Secure)

PASSEC is a minimal, clean, lightweight, fast, and privacy-focused password manager. It is designed to be fully offline-first, ensuring all user data remains locally on the device by default.

---

## Key Features

1. **Spaces System**:
   - Organize credentials into distinct compartments (e.g., Work, Streaming, Social, Banking, Games).
   - Create, rename, delete, import, or export spaces.
   - Access to each Space requires verification.

2. **Account Management**:
   - Save account credentials with fields like Username/Email, Password, Notes, Website URL, and Recovery fields.
   - Secure visual password reveal with a temporary 15-second countdown.
   - Quick copy button with secure 30-second clipboard clearing.
   - Add/remove accounts to Favorites for easy access.

3. **Robust Local Security & Cryptography**:
   - **AES-256-GCM** authenticated encryption for sensitive passwords and account metadata.
   - **PBKDF2-HMAC-SHA256** key derivation with 600,000 iterations for secure master key protection.
   - Native device biometrics (Fingerprint/Face Unlock) with safe PIN fallback.
   - Failed PIN login protection with exponential backoff lockout.

4. **Encrypted Backups**:
   - Export selected spaces into an encrypted `.passec` file.
   - Restore database from an encrypted backup file using your backup password.

---

## Tech Stack

- **Framework**: Flutter (Dart)
- **Database**: Drift (Reactive SQLite wrapper)
- **State Management**: Riverpod
- **Secure Key Storage**: Flutter Secure Storage (Android Keystore / iOS Keychain)
- **Local Authentication**: Local Auth (Fingerprint, Face ID, Device Passcode)

---

## How to Build & Run

### Prerequisites
Make sure you have Flutter installed and configured globally.

- **Flutter SDK** (v3.19.0 or higher)
- **Dart SDK** (v3.3.0 or higher)

### Setup Instructions

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Code Generation**:
   Drift and Riverpod code generators must be run to generate the database and state providers:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run the App**:
   - **Web (Chrome)**:
     ```bash
     flutter run -d chrome
     ```
   - **Windows Desktop**:
     ```bash
     flutter run -d windows
     ```
   - **Android / iOS**:
     ```bash
     flutter run
     ```

---

## Security Architecture

- **App Initialization**:
  - The app generates a cryptographically secure random 256-bit **Master Key** upon first startup.
  - If a PIN is created, the Master Key is encrypted using a key derived from the PIN via PBKDF2 (600,000 iterations) and saved to secure storage.
  - If Biometrics are enabled, the Master Key is stored directly in secure storage with biometric-only access conditions (`enforceBiometrics: true`), which relies on Android Keystore / iOS Keychain hardware security.

- **Data Encryption**:
  - Drift SQLite database stores the accounts.
  - Sensitive columns (`encrypted_password`, `username`, `notes`, `recovery_email`, `recovery_phone_number`, `website_url`) are encrypted using **AES-256-GCM** using the Master Key.
  - Decryption happens in memory only when required and is never cached permanently.

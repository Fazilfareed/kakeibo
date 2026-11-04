import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../settings/data/settings_repository.dart';
import 'lock_repository.dart';

final lockRepositoryProvider = Provider<LockRepository>(
  (ref) => LockRepository(const KeystoreSecretStore()),
);

/// The user's lock choices, kept in the settings table (PRD §11.2); the
/// secrets themselves are in secure storage.
class LockSettings {
  const LockSettings({required this.enabled, required this.biometric, required this.timeout});

  final bool enabled;
  final bool biometric;

  /// How long the app may sit in the background before it locks again.
  final Duration timeout;

  static const keyEnabled = 'lock_enabled';
  static const keyBiometric = 'biometric_enabled';
  static const keyTimeout = 'lock_timeout_sec';

  factory LockSettings.fromMap(Map<String, String> m) => LockSettings(
    enabled: m[keyEnabled] == 'true',
    biometric: m[keyBiometric] == 'true',
    timeout: Duration(seconds: int.tryParse(m[keyTimeout] ?? '') ?? 60),
  );
}

/// Null while settings load, so the app never flashes data before locking.
final lockSettingsProvider = Provider<LockSettings?>((ref) {
  final m = ref.watch(settingsProvider).value;
  return m == null ? null : LockSettings.fromMap(m);
});

/// Fingerprint / face unlock (FR-06), behind an interface for tests.
class Biometrics {
  const Biometrics([this._auth]);
  final LocalAuthentication? _auth;
  LocalAuthentication get _a => _auth ?? LocalAuthentication();

  Future<bool> available() async {
    try {
      return await _a.canCheckBiometrics && (await _a.getAvailableBiometrics()).isNotEmpty;
    } on Object {
      return false;
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      return await _a.authenticate(localizedReason: reason, biometricOnly: true);
    } on Object {
      return false;
    }
  }
}

final biometricsProvider = Provider<Biometrics>((ref) => const Biometrics());

final biometricsAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(biometricsProvider).available(),
);

/// Whether this session has been unlocked. Locking again happens on start
/// and after [LockSettings.timeout] in the background.
class SessionLock extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;
  void lock() => state = false;
}

final sessionUnlockedProvider = NotifierProvider<SessionLock, bool>(SessionLock.new);

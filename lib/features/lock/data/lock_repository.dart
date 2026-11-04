import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where secrets live. Android Keystore-backed in the app; in memory in tests.
abstract class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class KeystoreSecretStore implements SecretStore {
  const KeystoreSecretStore([this._storage = const FlutterSecureStorage()]);
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);
  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// The outcome of a PIN or recovery-code check.
sealed class UnlockResult {
  const UnlockResult();
}

class Unlocked extends UnlockResult {
  const Unlocked();
}

class WrongCode extends UnlockResult {
  const WrongCode({required this.attemptsLeft});

  /// Tries before the next lockout.
  final int attemptsLeft;
}

class LockedOut extends UnlockResult {
  const LockedOut(this.wait);
  final Duration wait;
}

/// App lock secrets (PRD §13, FR-06–08): a 4–6 digit PIN and a 12-character
/// recovery code, both stored only as PBKDF2-HMAC-SHA256 hashes with random
/// salts. Five wrong tries start an increasing lockout.
class LockRepository {
  LockRepository(
    this._store, {
    this.iterations = 100000,
    DateTime Function()? clock,
    Future<String> Function(String secret, String salt)? hasher,
  }) : _now = clock ?? DateTime.now,
       _hasher = hasher; // ignore: prefer_initializing_formals

  final SecretStore _store;
  final int iterations;
  final DateTime Function() _now;

  /// Replaces PBKDF2 in widget tests, where isolates don't run.
  final Future<String> Function(String secret, String salt)? _hasher;

  static const freeAttempts = 5;

  /// Lockout after the 5th, 6th, 7th… wrong try (FR-08).
  static const lockouts = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(hours: 1),
  ];

  static const _pinHash = 'pin_hash';
  static const _pinSalt = 'pin_salt';
  static const _pinLength = 'pin_length';
  static const _codeHash = 'recovery_hash';
  static const _codeSalt = 'recovery_salt';
  static const _failures = 'pin_failures';
  static const _lockedUntil = 'pin_locked_until';

  /// No 0/O or 1/I/L, so the code is easy to copy by hand.
  static const _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  Future<bool> hasPin() async => await _store.read(_pinHash) != null;

  Future<int> pinLength() async => int.tryParse(await _store.read(_pinLength) ?? '') ?? 4;

  /// Sets a new PIN and a new recovery code, which is returned once to show
  /// the user ("ABCD-EFGH-JKMN"). Clears any lockout.
  Future<String> setPin(String pin) async {
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) throw ArgumentError('PIN must be 4 to 6 digits');
    final rnd = Random.secure();
    final code = List.generate(12, (_) => _alphabet[rnd.nextInt(_alphabet.length)]).join();
    final pinSalt = _salt(rnd);
    final codeSalt = _salt(rnd);
    final hashes = await Future.wait([_hash(pin, pinSalt), _hash(code, codeSalt)]);
    await _store.write(_pinHash, hashes[0]);
    await _store.write(_pinSalt, pinSalt);
    await _store.write(_pinLength, '${pin.length}');
    await _store.write(_codeHash, hashes[1]);
    await _store.write(_codeSalt, codeSalt);
    await _resetFailures();
    return formatCode(code);
  }

  Future<UnlockResult> checkPin(String pin) => _check(pin, _pinHash, _pinSalt);

  /// FR-07: the recovery code unlocks so a new PIN can be set. Spaces,
  /// dashes and lower case are ignored.
  Future<UnlockResult> checkRecoveryCode(String code) =>
      _check(normalizeCode(code), _codeHash, _codeSalt);

  /// How long the user must still wait, or null.
  Future<Duration?> lockoutRemaining() async {
    final until = DateTime.tryParse(await _store.read(_lockedUntil) ?? '');
    if (until == null) return null;
    final left = until.difference(_now());
    return left.isNegative ? null : left;
  }

  /// Removes the PIN, the recovery code and the attempt counter.
  Future<void> clear() async {
    for (final k in [_pinHash, _pinSalt, _pinLength, _codeHash, _codeSalt]) {
      await _store.delete(k);
    }
    await _resetFailures();
  }

  static String normalizeCode(String code) =>
      code.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

  static String formatCode(String code) =>
      [for (var i = 0; i < code.length; i += 4) code.substring(i, min(i + 4, code.length))]
          .join('-');

  // ---------------------------------------------------------------------------

  Future<UnlockResult> _check(String secret, String hashKey, String saltKey) async {
    final wait = await lockoutRemaining();
    if (wait != null) return LockedOut(wait);
    final hash = await _store.read(hashKey);
    final salt = await _store.read(saltKey);
    if (hash == null || salt == null) return const WrongCode(attemptsLeft: 0);
    if (await _hash(secret, salt) == hash) {
      await _resetFailures();
      return const Unlocked();
    }
    final failures = (int.tryParse(await _store.read(_failures) ?? '') ?? 0) + 1;
    await _store.write(_failures, '$failures');
    if (failures < freeAttempts) return WrongCode(attemptsLeft: freeAttempts - failures);
    final lockout = lockouts[min(failures - freeAttempts, lockouts.length - 1)];
    await _store.write(_lockedUntil, _now().add(lockout).toIso8601String());
    return LockedOut(lockout);
  }

  Future<void> _resetFailures() async {
    await _store.delete(_failures);
    await _store.delete(_lockedUntil);
  }

  static String _salt(Random rnd) => base64Encode(List.generate(16, (_) => rnd.nextInt(256)));

  /// PBKDF2 off the UI isolate: 100k rounds take a moment in pure Dart.
  Future<String> _hash(String secret, String salt) {
    if (_hasher != null) return _hasher(secret, salt);
    final rounds = iterations;
    return Isolate.run(() async {
      final key = await Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: rounds,
        bits: 256,
      ).deriveKeyFromPassword(password: secret, nonce: base64Decode(salt));
      return base64Encode(await key.extractBytes());
    });
  }
}

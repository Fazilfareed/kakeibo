import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/features/lock/data/lock_repository.dart';

class _MemoryStore implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  late _MemoryStore store;
  late DateTime now;
  late LockRepository repo;

  setUp(() {
    store = _MemoryStore();
    now = DateTime(2026, 11, 5, 10);
    // Fewer rounds keep tests fast; the app uses 100,000.
    repo = LockRepository(store, iterations: 1000, clock: () => now);
  });

  test('the PIN and code are stored only as salted hashes', () async {
    final code = await repo.setPin('2580');
    expect(await repo.hasPin(), isTrue);
    expect(await repo.pinLength(), 4);
    expect(code, matches(RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$')));
    expect(code, isNot(matches(RegExp('[01OIL]'))), reason: 'no look-alike characters');
    final stored = store.values.values.join(' ');
    expect(stored.contains('2580'), isFalse);
    expect(stored.contains(LockRepository.normalizeCode(code)), isFalse);

    // Same PIN, different salt, different hash.
    final first = store.values['pin_hash'];
    await repo.setPin('2580');
    expect(store.values['pin_hash'], isNot(first));
  });

  test('right PIN unlocks, wrong PIN counts down', () async {
    await repo.setPin('135790');
    expect(await repo.checkPin('135790'), isA<Unlocked>());
    final wrong = await repo.checkPin('000000');
    expect(wrong, isA<WrongCode>().having((w) => w.attemptsLeft, 'left', 4));
    expect(await repo.checkPin('135790'), isA<Unlocked>());
    expect(
      await repo.checkPin('111111'),
      isA<WrongCode>().having((w) => w.attemptsLeft, 'left', 4),
      reason: 'a success resets the count',
    );
  });

  test('five wrong tries lock out, and each later miss waits longer (FR-08)', () async {
    await repo.setPin('2580');
    for (var i = 0; i < 4; i++) {
      expect(await repo.checkPin('1111'), isA<WrongCode>());
    }
    expect(
      await repo.checkPin('1111'),
      isA<LockedOut>().having((l) => l.wait, 'wait', const Duration(seconds: 30)),
    );
    expect(await repo.checkPin('2580'), isA<LockedOut>(), reason: 'even the right PIN waits');

    now = now.add(const Duration(seconds: 31));
    expect(await repo.lockoutRemaining(), isNull);
    expect(
      await repo.checkPin('1111'),
      isA<LockedOut>().having((l) => l.wait, 'wait', const Duration(minutes: 1)),
    );
    now = now.add(const Duration(minutes: 2));
    expect(
      await repo.checkPin('1111'),
      isA<LockedOut>().having((l) => l.wait, 'wait', const Duration(minutes: 5)),
    );
    now = now.add(const Duration(minutes: 6));
    expect(await repo.checkPin('2580'), isA<Unlocked>());
    expect(await repo.lockoutRemaining(), isNull);
  });

  test('the recovery code unlocks, ignoring case, spaces and dashes (FR-07)', () async {
    final code = await repo.setPin('2580');
    final messy = ' ${code.toLowerCase().replaceAll('-', ' ')} ';
    expect(await repo.checkRecoveryCode(messy), isA<Unlocked>());
    expect(await repo.checkRecoveryCode('AAAA-BBBB-CCCC'), isA<WrongCode>());

    // A new PIN gets a new code; the old one stops working.
    final next = await repo.setPin('9999');
    expect(next, isNot(code));
    expect(await repo.checkRecoveryCode(code), isA<WrongCode>());
    expect(await repo.checkPin('9999'), isA<Unlocked>());
  });

  test('clear removes every secret', () async {
    await repo.setPin('2580');
    await repo.checkPin('1111');
    await repo.clear();
    expect(store.values, isEmpty);
    expect(await repo.hasPin(), isFalse);
  });

  test('only 4 to 6 digit PINs are accepted', () {
    expect(() => repo.setPin('123'), throwsArgumentError);
    expect(() => repo.setPin('1234567'), throwsArgumentError);
    expect(() => repo.setPin('12a4'), throwsArgumentError);
  });
}

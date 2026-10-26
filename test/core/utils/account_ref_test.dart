import 'package:daftar_afandi/core/utils/account_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeAccountRef', () {
    test('Arabic and Persian digits become Latin', () {
      expect(normalizeAccountRef('٠١٠١٢٣٤٥٦٧٨'), '01012345678');
      expect(normalizeAccountRef('۰۱۰'), '010');
    });

    test('trims the ends; empty is null', () {
      expect(normalizeAccountRef('  shop@instapay '), 'shop@instapay');
      expect(normalizeAccountRef('   '), isNull);
      expect(normalizeAccountRef(''), isNull);
    });
  });

  group('checkAccountRef', () {
    test('accepts a wallet number and an InstaPay address', () {
      expect(checkAccountRef('01012345678'), isNull);
      expect(checkAccountRef('my.shop_1-a@instapay'), isNull);
    });

    test('40 characters pass, 41 are too long', () {
      expect(checkAccountRef('1' * 40), isNull);
      expect(checkAccountRef('1' * 41), AccountRefProblem.tooLong);
    });

    test('refuses Arabic letters, spaces and other symbols', () {
      expect(checkAccountRef('محفظة'), AccountRefProblem.invalidCharacters);
      expect(checkAccountRef('010 123'), AccountRefProblem.invalidCharacters);
      expect(checkAccountRef('010#1'), AccountRefProblem.invalidCharacters);
    });
  });
}

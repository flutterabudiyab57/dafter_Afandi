import 'package:daftar_afandi/core/utils/phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseShopPhone', () {
    test('valid numbers come back as Latin digits', () {
      expect(parseShopPhone('01012345678'), const PhoneOk('01012345678'));
      expect(
        parseShopPhone('+20 100 123 4567'),
        const PhoneOk('+201001234567'),
      );
    });

    test('Arabic-Indic and Persian digits, spaces and dashes', () {
      expect(parseShopPhone('٠١٠ ١٢٣٤-٥٦٧٨'), const PhoneOk('01012345678'));
      expect(parseShopPhone('۰۱۰۱۲۳۴۵۶۷۸'), const PhoneOk('01012345678'));
      expect(parseShopPhone('+٢٠١٠٠١٢٣٤٥٦٧'), const PhoneOk('+201001234567'));
    });

    test('empty', () {
      expect(parseShopPhone(''), isA<PhoneEmpty>());
      expect(parseShopPhone('   '), isA<PhoneEmpty>());
      expect(parseShopPhone(' - '), isA<PhoneEmpty>());
    });

    test('boundaries 6 / 7 / 15 / 16 digits', () {
      expect(parseShopPhone('123456'), isA<PhoneTooShort>());
      expect(parseShopPhone('1234567'), const PhoneOk('1234567'));
      expect(
        parseShopPhone('123456789012345'),
        const PhoneOk('123456789012345'),
      );
      expect(parseShopPhone('1234567890123456'), isA<PhoneTooLong>());
    });

    test('the leading + does not count as a digit', () {
      expect(parseShopPhone('+123456'), isA<PhoneTooShort>());
      expect(parseShopPhone('+1234567'), const PhoneOk('+1234567'));
      expect(parseShopPhone('+1234567890123456'), isA<PhoneTooLong>());
      expect(parseShopPhone('+'), isA<PhoneTooShort>());
    });

    test('+ only at the start, and only once', () {
      expect(parseShopPhone('12+34567'), isA<PhoneInvalidChars>());
      expect(parseShopPhone('1234567+'), isA<PhoneInvalidChars>());
      expect(parseShopPhone('++1234567'), isA<PhoneInvalidChars>());
    });

    test('other characters are invalid', () {
      expect(parseShopPhone('(010)1234567'), isA<PhoneInvalidChars>());
      expect(parseShopPhone('010.1234567'), isA<PhoneInvalidChars>());
      expect(parseShopPhone('abcdefg'), isA<PhoneInvalidChars>());
    });
  });
}

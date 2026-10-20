import 'package:daftar_afandi/core/widgets/number_fields.dart';
import 'package:flutter_test/flutter_test.dart';

String apply(int maxDecimals, String from, String to) =>
    DecimalInputFormatter(maxDecimals)
        .formatEditUpdate(
          TextEditingValue(text: from),
          TextEditingValue(text: to),
        )
        .text;

void main() {
  test('accepts digits in both sets, grouping and one decimal point', () {
    expect(apply(2, '', '1,234.5'), '1,234.5');
    expect(apply(2, '', '٧٫٥٠'), '٧٫٥٠');
    expect(apply(3, '', '٢٬٣٧٥'), '٢٬٣٧٥');
  });

  test('a decimal past the limit cannot be typed', () {
    expect(apply(3, '2.375', '2.3755'), '2.375');
    expect(apply(2, '7.50', '7.505'), '7.50');
    expect(apply(2, '٧٫٥٠', '٧٫٥٠٥'), '٧٫٥٠');
  });

  test('letters, signs and a second point are ignored', () {
    expect(apply(2, '1', '1a'), '1');
    expect(apply(2, '1', '-1'), '1');
    expect(apply(2, '1.2', '1.2.'), '1.2');
  });

  test('no decimals allowed with 0', () {
    expect(apply(0, '1', '1.'), '1');
    expect(apply(0, '1', '12'), '12');
  });
}

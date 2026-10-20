import 'package:daftar_afandi/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fold calls onOk for Ok', () {
    const Result<int, String> r = Ok(2);
    expect(r.fold((v) => 'ok $v', (e) => 'err $e'), 'ok 2');
  });

  test('fold calls onErr for Err', () {
    const Result<int, String> r = Err('bad');
    expect(r.fold((v) => 'ok $v', (e) => 'err $e'), 'err bad');
  });

  test('switch is exhaustive over Ok and Err', () {
    String describe(Result<int, String> r) => switch (r) {
      Ok(:final value) => 'value $value',
      Err(:final error) => 'error $error',
    };
    expect(describe(const Ok(1)), 'value 1');
    expect(describe(const Err('x')), 'error x');
  });

  test('equality is by value', () {
    expect(const Ok<int, String>(1), const Ok<int, String>(1));
    expect(const Err<int, String>('a'), const Err<int, String>('a'));
    expect(const Ok<int, String>(1), isNot(const Ok<int, String>(2)));
  });
}

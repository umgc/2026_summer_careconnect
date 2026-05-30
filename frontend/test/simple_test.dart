import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Simple test to verify setup', () {
    expect(1 + 1, 2);
  });

  test('basic string operations', () {
    expect('hello'.toUpperCase(), 'HELLO');
    expect('WORLD'.toLowerCase(), 'world');
  });

  test('list operations', () {
    final list = [1, 2, 3];
    expect(list.length, 3);
    expect(list.contains(2), isTrue);
    expect(list.contains(4), isFalse);
  });

  test('map operations', () {
    final map = {'key': 'value'};
    expect(map['key'], 'value');
    expect(map.containsKey('key'), isTrue);
  });

  test('null safety', () {
    String? nullable;
    expect(nullable, isNull);
    nullable = 'assigned';
    expect(nullable, isNotNull);
  });

  test('type checks', () {
    expect(42, isA<int>());
    expect(3.14, isA<double>());
    expect('test', isA<String>());
    expect(true, isA<bool>());
  });
}

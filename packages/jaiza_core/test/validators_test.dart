import 'package:jaiza_core/jaiza_core.dart';
import 'package:test/test.dart';

void main() {
  test('password needs 8+ characters, a letter and a number (15 §4.1)', () {
    expect(Validators.isValidPassword('abcd1234'), isTrue);
    expect(Validators.isValidPassword('pass word 9'), isTrue);
    expect(Validators.isValidPassword('abc1234'), isFalse); // 7 chars
    expect(Validators.isValidPassword('abcdefgh'), isFalse); // no number
    expect(Validators.isValidPassword('12345678'), isFalse); // no letter
  });
}

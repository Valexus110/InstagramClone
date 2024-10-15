import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:instagram_example/authentication/utils.dart';
import 'package:instagram_example/main.dart';
import 'package:instagram_example/profile/utils.dart';
import 'package:instagram_example/utils/utils.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'unit_tests.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('Validation test start, email, password, passworld length', () {
    test('email should validate', () {
      var result = emailValidation("user@email.com");
      expect(result, true);
    });
    test('password should validate', () {
      var result = passFormatValidation("Password1");
      expect(result, true);
    });
    test('password length should match', () {
      var result = passLengthValidation("password");
      expect(result, true);
    });
  });

  group('Profile tests, enumString should equal', () {
    test('enumString should equal', () {
      var result = getEnumString(StartPageEntries.feed);
      expect(result, locale.feed);
    });
  });

  group('Utils tests, datePattern should be equal to difference', () {
    test('datePattern should be equal to difference', () {
      var lessADay = datePattern(DateTime(2024,10,14,23), DateTime(2024,10,14,21));
      expect(lessADay, 'H:mm');
      var lessAWeek = datePattern(DateTime(2024,10,14), DateTime(2024,10,8));
      expect(lessAWeek, 'EEEE');
      var moreThanWeek = datePattern(DateTime(2024,10,14), DateTime(2024,10,1));
      expect(moreThanWeek, 'MMM, d');
    });
  });
}

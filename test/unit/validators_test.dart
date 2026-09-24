import 'package:employee_management/domain/core/validators/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns error when email is empty', () {
        expect(Validators.validateEmail(''), 'Email is required');
        expect(Validators.validateEmail(null), 'Email is required');
      });

      test('returns error for invalid email', () {
        expect(Validators.validateEmail('abc'), 'Enter a valid email address');
        expect(Validators.validateEmail('abc@'), 'Enter a valid email address');
        expect(Validators.validateEmail('@gmail.com'), 'Enter a valid email address');
      });

      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@gmail.com'), isNull);
        expect(Validators.validateEmail('user.name@domain.co'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error when password is empty', () {
        expect(Validators.validatePassword(''), 'Password is required');
        expect(Validators.validatePassword(null), 'Password is required');
      });

      test('returns error when password is too short', () {
        expect(Validators.validatePassword('12345'),
            'Password must be at least 6 characters');
      });

      test('returns null for valid password', () {
        expect(Validators.validatePassword('123456'), isNull);
        expect(Validators.validatePassword('strongpassword'), isNull);
      });
    });

    group('validateConfirmPassword', () {
      test('returns error when empty', () {
        expect(Validators.validateConfirmPassword('', 'pass'),
            'Confirm password is required');
      });

      test('returns error when passwords do not match', () {
        expect(Validators.validateConfirmPassword('abc', 'def'),
            'Passwords do not match');
      });

      test('returns null when passwords match', () {
        expect(Validators.validateConfirmPassword('abc', 'abc'), isNull);
      });
    });

    group('validateMobile', () {
      test('returns error when mobile is empty', () {
        expect(Validators.validateMobile(''), 'Mobile number is required');
      });

      test('returns error when mobile is not 10 digits', () {
        expect(Validators.validateMobile('12345'),
            'Mobile number must be 10 digits');
        expect(Validators.validateMobile('123456789012'),
            'Mobile number must be 10 digits');
      });

      test('returns null for valid 10-digit mobile', () {
        expect(Validators.validateMobile('9876543210'), isNull);
      });
    });

    group('validateRequired', () {
      test('returns error when field is empty', () {
        expect(Validators.validateRequired('', 'Name'), 'Name is required');
        expect(Validators.validateRequired(null, 'Name'), 'Name is required');
      });

      test('returns null when field has value', () {
        expect(Validators.validateRequired('John', 'Name'), isNull);
      });
    });

    group('validateName', () {
      test('returns error when name is empty', () {
        expect(Validators.validateName(''), 'Name is required');
      });

      test('returns null for valid name', () {
        expect(Validators.validateName('John'), isNull);
      });
    });
  });
}

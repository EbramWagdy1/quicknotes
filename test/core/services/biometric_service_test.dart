import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:quicknotes/core/services/biometric_service.dart';

class FakeLocalAuthentication extends Fake implements LocalAuthentication {
  bool canCheck = true;
  bool isSupported = true;
  bool authResult = true;

  @override
  Future<bool> get canCheckBiometrics async => canCheck;

  @override
  Future<bool> isDeviceSupported() async => isSupported;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    dynamic authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async => authResult;
}

void main() {
  group('BiometricService Tests', () {
    test(
      'canAuthenticate returns true when biometrics or device is supported',
      () async {
        final fakeAuth = FakeLocalAuthentication();
        final service = BiometricService(auth: fakeAuth);

        expect(await service.canAuthenticate(), true);
      },
    );

    test('canAuthenticate returns false when neither is supported', () async {
      final fakeAuth = FakeLocalAuthentication()
        ..canCheck = false
        ..isSupported = false;
      final service = BiometricService(auth: fakeAuth);

      expect(await service.canAuthenticate(), false);
    });

    test('authenticate returns result from LocalAuthentication', () async {
      final fakeAuth = FakeLocalAuthentication()..authResult = true;
      final service = BiometricService(auth: fakeAuth);

      expect(await service.authenticate(), true);

      fakeAuth.authResult = false;
      expect(await service.authenticate(), false);
    });
  });
}

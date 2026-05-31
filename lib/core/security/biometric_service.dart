import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isAvailable() async => await _localAuth.canCheckBiometrics;

  Future<bool> authenticate() async {
    return await _localAuth.authenticate(
      localizedReason: 'Authenticate to proceed',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }
}

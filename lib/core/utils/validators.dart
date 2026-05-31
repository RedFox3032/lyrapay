class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Must contain an uppercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Must contain a number';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? firstName(String? value) {
    if (value == null || value.isEmpty) return 'First name is required';
    if (value.length < 2) return 'Name is too short';
    if (value.length > 50) return 'Name is too long';
    return null;
  }

  static String? lastName(String? value) {
    if (value == null || value.isEmpty) return 'Last name is required';
    if (value.length < 2) return 'Name is too short';
    if (value.length > 50) return 'Name is too long';
    return null;
  }

  static String? lyraTag(String? value) {
    if (value == null || value.isEmpty) return 'LyraTag is required';
    if (value.length < 4) return 'Must be at least 4 characters';
    if (value.length > 30) return 'Must be 30 characters or less';
    final regex = RegExp(r'^[a-z0-9][a-z0-9._]{2,28}[a-z0-9]\$');
    if (!regex.hasMatch(value)) {
      return 'Only lowercase letters, numbers, dots, underscores';
    }
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'PIN is required';
    if (value.length != 4) return 'PIN must be 4 digits';
    if (!RegExp(r'^\d{4}\$').hasMatch(value)) return 'PIN must contain only digits';
    return null;
  }

  static String? voucherCode(String? value) {
    if (value == null || value.isEmpty) return 'Voucher code is required';
    final clean = value.replaceAll('-', '');
    if (clean.length != 15) return 'Must be 15 characters';
    final regex = RegExp(r'^[A-HJ-NP-Z2-9]{15}\$');
    if (!regex.hasMatch(clean.toUpperCase())) return 'Invalid voucher code format';
    return null;
  }
}

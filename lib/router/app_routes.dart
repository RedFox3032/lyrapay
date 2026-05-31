class AppRoutes {
  AppRoutes._();
  static const splash        = '/';
  static const onboarding    = '/onboarding';
  static const register      = '/register';
  static const login         = '/login';
  static const lyraTagClaim  = '/claim-tag';
  static const forgotPassword= '/forgot-password';
  static const home          = '/home';
  static const send          = '/send';
  static const request       = '/request';
  static const addMoney      = '/add-money';
  static const voucherInput  = '/add-money/voucher';
  static const voucherConfirm= '/add-money/voucher/confirm';
  static const voucherSuccess= '/add-money/voucher/success';
  static const activity      = '/activity';
  static const transactionDetail = '/activity/detail/:id';
  static const profile       = '/profile';
  static const editProfile   = '/profile/edit';
  static const securitySettings = '/settings/security';
  static const setPin        = '/settings/security/set-pin';
  static const enterPin      = '/pin';
  static const qrDisplay     = '/qr';
  static const qrScan        = '/qr/scan';
}

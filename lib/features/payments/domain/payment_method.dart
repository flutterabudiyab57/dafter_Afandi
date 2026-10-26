/// How money was paid (decision Q23). `card` exists in storage but is not
/// offered in the user interface.
enum PaymentMethod { cash, wallet, instapay, card }

/// The methods the user can pick.
const List<PaymentMethod> offeredPaymentMethods = [
  PaymentMethod.cash,
  PaymentMethod.wallet,
  PaymentMethod.instapay,
];

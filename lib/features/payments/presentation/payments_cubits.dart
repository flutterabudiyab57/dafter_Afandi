import 'package:get_it/get_it.dart';

import '../domain/account_suggestions_repository.dart';
import 'cubits/payment_split_cubit.dart';

/// Builds the payment cubits shared by the five payment forms (006 US6).
/// The app uses [AppPaymentsCubits]; widget tests pass a bundle built on
/// fakes.
abstract class PaymentsCubits {
  PaymentSplitCubit paymentSplit();
}

/// Cubits built on the repositories in [locator].
final class AppPaymentsCubits implements PaymentsCubits {
  const AppPaymentsCubits(this.locator);

  final GetIt locator;

  @override
  PaymentSplitCubit paymentSplit() =>
      PaymentSplitCubit(locator<AccountSuggestionsRepository>());
}

import 'package:daftar_afandi/features/payments/domain/account_suggestions_repository.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:daftar_afandi/features/payments/presentation/cubits/payment_split_cubit.dart';
import 'package:daftar_afandi/features/payments/presentation/payments_cubits.dart';

/// In-memory account numbers used before, per method, most recent first.
final class FakeAccountSuggestions implements AccountSuggestionsRepository {
  FakeAccountSuggestions([Map<PaymentMethod, List<String>>? used])
    : used = used ?? {};

  final Map<PaymentMethod, List<String>> used;

  @override
  Future<List<AccountSuggestion>> suggestions(PaymentMethod method) async => [
    for (final ref in (used[method] ?? const <String>[]).take(5))
      AccountSuggestion(
        method: method,
        accountRef: ref,
        lastUsedAt: DateTime.utc(2026, 10, 20),
      ),
  ];
}

final class FakePaymentsCubits implements PaymentsCubits {
  FakePaymentsCubits([FakeAccountSuggestions? accounts])
    : accounts = accounts ?? FakeAccountSuggestions();

  final FakeAccountSuggestions accounts;

  @override
  PaymentSplitCubit paymentSplit() => PaymentSplitCubit(accounts);
}

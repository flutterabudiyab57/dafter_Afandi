import 'payment_method.dart';
import 'payment_split.dart';

/// The owner's account numbers used before, offered on payment forms so
/// they are picked, not retyped (FR-034).
abstract interface class AccountSuggestionsRepository {
  /// Up to five distinct numbers used with [method], most recent first.
  /// Always empty for cash.
  Future<List<AccountSuggestion>> suggestions(PaymentMethod method);
}

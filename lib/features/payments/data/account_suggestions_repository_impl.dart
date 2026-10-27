import '../../../core/database/daos/payment_parts_dao.dart';
import '../domain/account_suggestions_repository.dart';
import '../domain/payment_method.dart';
import '../domain/payment_split.dart';
import 'payment_parts_writer.dart';

final class AccountSuggestionsRepositoryImpl
    implements AccountSuggestionsRepository {
  const AccountSuggestionsRepositoryImpl(this._dao);

  final PaymentPartsDao _dao;

  @override
  Future<List<AccountSuggestion>> suggestions(PaymentMethod method) async {
    if (method == PaymentMethod.cash) return const [];
    return [
      for (final r in await _dao.suggestions(PaymentMappers.toDb(method)))
        AccountSuggestion(
          method: method,
          accountRef: r.accountRef,
          lastUsedAt: r.lastUsedAt,
        ),
    ];
  }
}

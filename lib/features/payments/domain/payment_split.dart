import 'package:equatable/equatable.dart';

import '../../../core/utils/account_ref.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/result.dart';
import 'payment_method.dart';

/// The most a part may be, as for any amount the owner types.
const int maxPartPiasters = 1000000000;

/// The most parts one payment may have: one per offered method (FR-036).
const int maxPaymentParts = 3;

/// One piece of a payment in one method (data-model "PaymentPart").
final class PaymentPart extends Equatable {
  const PaymentPart({
    required this.method,
    required this.amountPiasters,
    this.accountRef,
  });

  final PaymentMethod method;

  /// Above 0.
  final int amountPiasters;

  /// The owner's own account the money arrived in or left from. Only on
  /// wallet and InstaPay parts.
  final String? accountRef;

  @override
  List<Object?> get props => [method, amountPiasters, accountRef];
}

/// A part as typed in the form.
final class PaymentPartInput extends Equatable {
  const PaymentPartInput({
    required this.method,
    this.amountText = '',
    this.accountText = '',
  });

  final PaymentMethod method;
  final String amountText;
  final String accountText;

  @override
  List<Object?> get props => [method, amountText, accountText];
}

/// An account number used before, offered so it is picked, not retyped.
final class AccountSuggestion extends Equatable {
  const AccountSuggestion({
    required this.method,
    required this.accountRef,
    required this.lastUsedAt,
  });

  final PaymentMethod method;
  final String accountRef;
  final DateTime lastUsedAt;

  @override
  List<Object?> get props => [method, accountRef, lastUsedAt];
}

/// How one payment was made: 1 to 3 parts that add up to the amount paid
/// (FR-036, FR-037). An empty split means nothing was paid.
final class PaymentSplit extends Equatable {
  const PaymentSplit._(this.parts);

  /// Nothing paid: no parts are written.
  static const PaymentSplit none = PaymentSplit._([]);

  /// The unsplit case.
  factory PaymentSplit.single(
    PaymentMethod method,
    int amountPiasters, {
    String? accountRef,
  }) {
    if (amountPiasters <= 0) return none;
    return PaymentSplit._([
      PaymentPart(
        method: method,
        amountPiasters: amountPiasters,
        accountRef: _usesAccount(method) ? accountRef : null,
      ),
    ]);
  }

  final List<PaymentPart> parts;

  int get total => parts.fold(0, (sum, p) => sum + p.amountPiasters);

  bool get isEmpty => parts.isEmpty;

  /// Part 1, whose method the header and ledger `payment_method` keep.
  PaymentPart get first => parts.first;

  /// Validates typed parts against [totalPiasters], collecting every error.
  ///
  /// A single part with an empty amount takes the whole total, so an unsplit
  /// payment needs no typing. A total of 0 is "nothing paid".
  static Result<PaymentSplit, List<PaymentSplitError>> create({
    required int totalPiasters,
    required List<PaymentPartInput> inputs,
  }) {
    if (totalPiasters <= 0) return const Ok(none);
    final errors = <PaymentSplitError>[];
    if (inputs.isEmpty || inputs.length > maxPaymentParts) {
      return Err([TooManyParts(inputs.length)]);
    }
    final seen = <PaymentMethod>{};
    final parts = <PaymentPart>[];
    for (final (i, input) in inputs.indexed) {
      if (!offeredPaymentMethods.contains(input.method) ||
          !seen.add(input.method)) {
        errors.add(MethodRepeated(i));
      }
      int? amount;
      if (inputs.length == 1 && input.amountText.trim().isEmpty) {
        amount = totalPiasters;
      } else {
        amount = tryParsePiasters(input.amountText);
        if (amount == null || amount > maxPartPiasters) {
          errors.add(PartAmountInvalid(i));
          amount = null;
        } else if (amount == 0) {
          errors.add(PartAmountZero(i));
          amount = null;
        }
      }
      final account = normalizeAccountRef(input.accountText);
      if (account != null) {
        if (!_usesAccount(input.method)) {
          errors.add(AccountNotAllowed(i));
        } else {
          switch (checkAccountRef(account)) {
            case AccountRefProblem.tooLong:
              errors.add(AccountTooLong(i));
            case AccountRefProblem.invalidCharacters:
              errors.add(AccountInvalid(i));
            case null:
          }
        }
      }
      if (amount != null) {
        parts.add(
          PaymentPart(
            method: input.method,
            amountPiasters: amount,
            accountRef: _usesAccount(input.method) ? account : null,
          ),
        );
      }
    }
    if (errors.isEmpty) {
      final sum = parts.fold(0, (s, p) => s + p.amountPiasters);
      if (sum != totalPiasters) errors.add(SumMismatch(sum - totalPiasters));
    }
    if (errors.isNotEmpty) return Err(errors);
    return Ok(PaymentSplit._(List.unmodifiable(parts)));
  }

  static bool _usesAccount(PaymentMethod m) =>
      m == PaymentMethod.wallet || m == PaymentMethod.instapay;

  @override
  List<Object?> get props => [parts];
}

/// Why typed parts cannot be saved. [index] is the part, from 0.
sealed class PaymentSplitError extends Equatable {
  const PaymentSplitError(this.index);

  /// The part it belongs to, or null for the payment as a whole.
  final int? index;

  @override
  List<Object?> get props => [runtimeType, index];
}

final class PartAmountInvalid extends PaymentSplitError {
  const PartAmountInvalid(int super.index);
}

final class PartAmountZero extends PaymentSplitError {
  const PartAmountZero(int super.index);
}

final class MethodRepeated extends PaymentSplitError {
  const MethodRepeated(int super.index);
}

final class AccountInvalid extends PaymentSplitError {
  const AccountInvalid(int super.index);
}

final class AccountTooLong extends PaymentSplitError {
  const AccountTooLong(int super.index);
}

/// An account number on cash.
final class AccountNotAllowed extends PaymentSplitError {
  const AccountNotAllowed(int super.index);
}

final class TooManyParts extends PaymentSplitError {
  const TooManyParts(this.count) : super(null);

  final int count;

  @override
  List<Object?> get props => [...super.props, count];
}

/// The parts add up to [differencePiasters] more (positive) or less
/// (negative) than the amount paid.
final class SumMismatch extends PaymentSplitError {
  const SumMismatch(this.differencePiasters) : super(null);

  final int differencePiasters;

  @override
  List<Object?> get props => [...super.props, differencePiasters];
}

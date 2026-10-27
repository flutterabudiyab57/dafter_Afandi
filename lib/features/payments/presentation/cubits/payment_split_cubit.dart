import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/decimal_text.dart';
import '../../../../core/utils/money.dart';
import '../../domain/account_suggestions_repository.dart';
import '../../domain/payment_method.dart';
import '../../domain/payment_split.dart';

final class PaymentSplitState extends Equatable {
  const PaymentSplitState({
    this.parts = const [PaymentPartInput(method: PaymentMethod.cash)],
    this.totalPiasters = 0,
    this.suggestions = const {},
    this.autoFirst = false,
  });

  /// One part, or two or three when split (FR-036). A single part with an
  /// empty amount takes the whole total.
  final List<PaymentPartInput> parts;

  /// The amount being paid.
  final int totalPiasters;

  /// Account numbers used before, per method, most recent first.
  final Map<PaymentMethod, List<String>> suggestions;

  /// Split, and part 1 not typed in since: part 1 follows as the rest of
  /// the total, so "300 cash, 200 wallet" is one amount to type.
  final bool autoFirst;

  bool get isSplit => parts.length > 1;

  /// When split: what the typed parts add up to minus the total; above 0
  /// is "over by", below 0 is "remaining". Unreadable amounts count as 0.
  /// Null when not split.
  int? get differencePiasters {
    if (!isSplit) return null;
    var sum = 0;
    for (final p in parts) {
      sum += tryParsePiasters(p.amountText) ?? 0;
    }
    return sum - totalPiasters;
  }

  bool get canSplit => parts.length < maxPaymentParts && totalPiasters > 0;

  PaymentSplitState copyWith({
    List<PaymentPartInput>? parts,
    int? totalPiasters,
    Map<PaymentMethod, List<String>>? suggestions,
    bool? autoFirst,
  }) => PaymentSplitState(
    parts: parts ?? this.parts,
    totalPiasters: totalPiasters ?? this.totalPiasters,
    suggestions: suggestions ?? this.suggestions,
    autoFirst: autoFirst ?? this.autoFirst,
  );

  @override
  List<Object?> get props => [parts, totalPiasters, suggestions, autoFirst];
}

/// The parts of one payment as typed (US6, contracts "PaymentSplitField").
/// Unsplit it is one method, cash first, taking the whole total, so a plain
/// payment needs no more taps than before (FR-038).
class PaymentSplitCubit extends Cubit<PaymentSplitState> {
  PaymentSplitCubit(this._accounts) : super(const PaymentSplitState());

  final AccountSuggestionsRepository _accounts;

  void totalChanged(int totalPiasters) {
    if (totalPiasters == state.totalPiasters) return;
    _emitParts(state.parts, totalPiasters: totalPiasters);
  }

  /// Adds a part in the first method no part uses yet. It starts empty and
  /// part 1 keeps the rest until the owner types in part 1.
  void split() {
    if (!state.canSplit) return;
    final used = {for (final p in state.parts) p.method};
    final method = offeredPaymentMethods.firstWhere(
      (m) => !used.contains(m),
      orElse: () => offeredPaymentMethods.first,
    );
    final wasSingle = !state.isSplit;
    _emitParts([
      ...state.parts,
      PaymentPartInput(method: method),
    ], autoFirst: wasSingle || state.autoFirst);
    _load(method);
  }

  /// Removes part [index] (not part 1); its amount goes back to part 1.
  /// Back to one part, part 1 takes the whole total again.
  void removePart(int index) {
    if (index <= 0 || index >= state.parts.length) return;
    final parts = [...state.parts];
    final removed = parts.removeAt(index);
    if (parts.length == 1) {
      parts[0] = _withAmount(parts[0], '');
      emit(state.copyWith(parts: parts, autoFirst: false));
      return;
    }
    if (!state.autoFirst) {
      final first = tryParsePiasters(parts[0].amountText) ?? 0;
      final back = tryParsePiasters(removed.amountText) ?? 0;
      parts[0] = _withAmount(parts[0], _text(first + back));
    }
    _emitParts(parts);
  }

  void methodChanged(int index, PaymentMethod method) {
    final p = state.parts[index];
    if (p.method == method) return;
    _replace(
      index,
      PaymentPartInput(
        method: method,
        amountText: p.amountText,
        // Cash has no account number (FR-034).
        accountText: method == PaymentMethod.cash ? '' : p.accountText,
      ),
    );
    _load(method);
  }

  void amountChanged(int index, String text) {
    if (index < 0 || index >= state.parts.length) return;
    final parts = [...state.parts]
      ..[index] = _withAmount(state.parts[index], text);
    // Typing in part 1 makes it the owner's own number.
    _emitParts(parts, autoFirst: index == 0 ? false : null);
  }

  void accountChanged(int index, String text) {
    final p = state.parts[index];
    _replace(
      index,
      PaymentPartInput(
        method: p.method,
        amountText: p.amountText,
        accountText: text,
      ),
    );
  }

  /// One cash part again, for the next record.
  void reset() => emit(
    PaymentSplitState(
      totalPiasters: state.totalPiasters,
      suggestions: state.suggestions,
    ),
  );

  void _replace(int index, PaymentPartInput part) {
    if (index < 0 || index >= state.parts.length) return;
    emit(state.copyWith(parts: [...state.parts]..[index] = part));
  }

  /// Emits [parts]; while part 1 follows, it becomes the total minus the
  /// other parts (empty when they already reach the total).
  void _emitParts(
    List<PaymentPartInput> parts, {
    int? totalPiasters,
    bool? autoFirst,
  }) {
    final total = totalPiasters ?? state.totalPiasters;
    final follow = autoFirst ?? state.autoFirst;
    var next = parts;
    if (follow && parts.length > 1) {
      var others = 0;
      for (final p in parts.skip(1)) {
        others += tryParsePiasters(p.amountText) ?? 0;
      }
      next = [...parts]..[0] = _withAmount(parts[0], _text(total - others));
    }
    emit(state.copyWith(parts: next, totalPiasters: total, autoFirst: follow));
  }

  Future<void> _load(PaymentMethod method) async {
    if (method == PaymentMethod.cash) return;
    try {
      final found = await _accounts.suggestions(method);
      if (isClosed) return;
      emit(
        state.copyWith(
          suggestions: {
            ...state.suggestions,
            method: [for (final s in found) s.accountRef],
          },
        ),
      );
    } on Object catch (e, st) {
      // Suggestions are a convenience; typing still works.
      addError(e, st);
    }
  }

  static PaymentPartInput _withAmount(PaymentPartInput p, String text) =>
      PaymentPartInput(
        method: p.method,
        amountText: text,
        accountText: p.accountText,
      );

  static String _text(int piasters) => piasters <= 0
      ? ''
      : formatScaledDecimal(piasters, scale: 2, minDecimals: 0);
}

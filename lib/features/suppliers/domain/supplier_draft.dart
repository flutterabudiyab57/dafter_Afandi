import 'package:equatable/equatable.dart';

import '../../../core/utils/result.dart';
import '../../customers/domain/customer_draft.dart';
import '../../customers/domain/customer_errors.dart';

/// Validated supplier fields, ready to save (research R12).
///
/// The fields follow the customer rules exactly, so validation and its
/// errors are shared with [CustomerDraft].
final class SupplierDraft extends Equatable {
  const SupplierDraft({
    required this.name,
    this.phone,
    this.address,
    this.note,
    this.openingBalancePiasters = 0,
  });

  final String name;
  final String? phone;
  final String? address;
  final String? note;

  /// Signed: positive means the shop owes the supplier, negative that the
  /// supplier owes the shop. 0 means none. Used only when adding.
  final int openingBalancePiasters;

  /// Validates every field and returns all errors at once.
  static Result<SupplierDraft, List<CustomerFieldError>> create({
    required String name,
    String phone = '',
    String address = '',
    String note = '',
    String openingText = '',
    bool openingInShopFavour = false,
  }) => switch (CustomerDraft.create(
    name: name,
    phone: phone,
    address: address,
    note: note,
    openingText: openingText,
    // The flag makes the opening negative in both drafts; for a supplier
    // that means the supplier owes the shop.
    openingInFavour: openingInShopFavour,
  )) {
    Ok(:final value) => Ok(
      SupplierDraft(
        name: value.name,
        phone: value.phone,
        address: value.address,
        note: value.note,
        openingBalancePiasters: value.openingBalancePiasters,
      ),
    ),
    Err(:final error) => Err(error),
  };

  @override
  List<Object?> get props => [
    name,
    phone,
    address,
    note,
    openingBalancePiasters,
  ];
}

import 'package:equatable/equatable.dart';

import '../../../core/utils/arabic_normalize.dart';

/// Someone who buys from the shop (data-model.md).
final class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.note,
    this.archived = false,
  });

  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? note;
  final bool archived;

  @override
  List<Object?> get props => [id, name, phone, address, note, archived];
}

/// A customer and their balance: the sum of their account rows. Positive
/// means the customer owes the shop (FR-013).
final class CustomerSummary extends Equatable {
  const CustomerSummary({
    required this.customer,
    required this.balancePiasters,
  });

  final Customer customer;
  final int balancePiasters;

  bool get owes => balancePiasters > 0;

  @override
  List<Object?> get props => [customer, balancePiasters];
}

/// The customer list's search and filter (FR-014).
final class CustomerQuery extends Equatable {
  const CustomerQuery({this.text = '', this.owesOnly = false});

  final String text;

  /// Only customers who owe money, highest balance first.
  final bool owesOnly;

  /// The search text folded like names are (002 research R4).
  String get normalizedText => arabicNormalize(text);

  CustomerQuery copyWith({String? text, bool? owesOnly}) => CustomerQuery(
    text: text ?? this.text,
    owesOnly: owesOnly ?? this.owesOnly,
  );

  @override
  List<Object?> get props => [text, owesOnly];
}

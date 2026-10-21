import 'package:equatable/equatable.dart';

import '../../../core/utils/arabic_normalize.dart';

/// Someone the shop buys from (data-model.md).
final class Supplier extends Equatable {
  const Supplier({
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

/// A supplier and their balance: the sum of their account rows. Positive
/// means the shop owes the supplier (FR-014).
final class SupplierSummary extends Equatable {
  const SupplierSummary({
    required this.supplier,
    required this.balancePiasters,
  });

  final Supplier supplier;
  final int balancePiasters;

  bool get owed => balancePiasters > 0;

  @override
  List<Object?> get props => [supplier, balancePiasters];
}

/// The supplier list's search and filter (FR-015).
final class SupplierQuery extends Equatable {
  const SupplierQuery({this.text = '', this.owedOnly = false});

  final String text;

  /// Only suppliers the shop owes, highest balance first.
  final bool owedOnly;

  /// The search text folded like names are (002 research R4).
  String get normalizedText => arabicNormalize(text);

  SupplierQuery copyWith({String? text, bool? owedOnly}) => SupplierQuery(
    text: text ?? this.text,
    owedOnly: owedOnly ?? this.owedOnly,
  );

  @override
  List<Object?> get props => [text, owedOnly];
}

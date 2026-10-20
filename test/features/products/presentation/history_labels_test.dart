import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/products/presentation/widgets/history_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final code in ['ar', 'en']) {
    final l10n = lookupAppLocalizations(Locale(code));

    test('$code: every stock entry type has its own label', () {
      final labels = StockEntryType.values
          .map((t) => stockEntryLabel(l10n, t))
          .toList();
      expect(labels.every((l) => l.trim().isNotEmpty), isTrue);
      expect(labels.toSet(), hasLength(StockEntryType.values.length));
    });

    test('$code: every adjustment reason has its own label', () {
      final labels = AdjustmentKind.values
          .map((k) => adjustmentKindLabel(l10n, k))
          .toList();
      expect(labels.every((l) => l.trim().isNotEmpty), isTrue);
      expect(labels.toSet(), hasLength(AdjustmentKind.values.length));
    });
  }
}

import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/widgets/digit_style_scope.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:daftar_afandi/features/payments/presentation/widgets/payment_parts_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/widget_harness.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<void> show(WidgetTester tester, Widget child) => pumpInApp(
    tester,
    l10n,
    DigitStyleScope(style: DigitStyle.latin, child: child),
  );

  testWidgets('a record from before 006 shows its one method (US6-7)', (
    tester,
  ) async {
    await show(
      tester,
      const PaymentPartsText(parts: [], method: PaymentMethod.wallet),
    );
    expect(find.text(l10n.methodWallet), findsOneWidget);
    expect(find.textContaining(l10n.paymentPartAccount('')), findsNothing);
  });

  testWidgets('nothing paid shows nothing', (tester) async {
    await show(tester, const PaymentPartsText(parts: []));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('one part: the method and its account', (tester) async {
    await show(
      tester,
      const PaymentPartsText(
        parts: [
          PaymentPart(
            method: PaymentMethod.instapay,
            amountPiasters: 100,
            accountRef: 'shop@ipa',
          ),
        ],
      ),
    );
    expect(find.text(l10n.methodInstapay), findsOneWidget);
    expect(
      find.text(l10n.paymentPartAccount(ltrIsolate('shop@ipa'))),
      findsOneWidget,
    );
  });
}

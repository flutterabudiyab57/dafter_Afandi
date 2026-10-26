import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_products.dart';
import '../../../helpers/fake_purchases.dart';
import '../../../helpers/fake_sales.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    final ar = locale == AppLocale.ar;
    String egp(String latin, String arabic) =>
        ar ? '$arabic\u00A0ج.م' : 'EGP\u00A0$latin';
    String doc(String latin) =>
        ltrIsolate(ar ? applyDigitStyle(latin, DigitStyle.arabicIndic) : latin);

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        late FakePurchasesStore store;
        late String tea;

        setUp(() {
          store = FakePurchasesStore();
          tea = store.products.seedProduct(
            'شاي',
            pricePiasters: 1250,
            stockMilli: 10000,
          );
        });

        Future<void> open(WidgetTester tester, String path) async {
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (!ar) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            products: FakeProductsCubits(store.products),
            sales: FakeSalesCubits(FakeSalesStore(store.products)),
            suppliers: FakeSuppliersCubits(store),
            purchases: FakePurchasesCubits(store),
            textScale: textScale,
          );
          await goTo(tester, path);
          expect(tester.takeException(), isNull);
        }

        Future<void> tapVisible(WidgetTester tester, Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        Finder field(String label) => find.widgetWithText(TextField, label);

        Future<void> typeIn(WidgetTester tester, Finder f, String text) async {
          await tester.ensureVisible(f);
          await tester.enterText(f, text);
          await tester.pumpAndSettle();
        }

        /// [qty] pieces of شاي at [cost] piasters, from [supplier] with
        /// [paid] paid now (null pays all).
        String buy({
          int qty = 1,
          int cost = 1000,
          String? supplier,
          String? supplierName,
          int? paid,
          String? ref,
          int lineDiscount = 0,
        }) {
          var d = const PurchaseDraft()
              .add(
                productId: tea,
                name: 'شاي',
                unit: UnitType.piece,
                salePricePiasters: 1250,
                unitCostPiasters: cost,
              )
              .updateLine(
                tea,
                qtyMilli: qty * milliPerUnit,
                lineDiscountPiasters: lineDiscount,
              )
              .withPaid(paid)
              .withSupplierRef(ref ?? '');
          if (supplier != null) {
            d = d.withSupplier(
              PurchaseSupplier(id: supplier, name: supplierName!),
            );
          }
          return store.seedPurchase(d);
        }

        /// Voids the open purchase with [reason] through the dialog.
        Future<void> voidWith(WidgetTester tester, String reason) async {
          await tapVisible(tester, find.text(l10n.purchaseVoidAction));
          await tester.enterText(field(l10n.reasonLabel), reason);
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.purchaseVoidAction),
          );
          await tester.pumpAndSettle();
        }

        testWidgets('US3-1, US3-2: newest first with number, supplier and '
            'mark; search by number, supplier and their invoice number', (
          tester,
        ) async {
          final v = store.seedSupplier('شركة النور');
          buy();
          buy(supplier: v, supplierName: 'شركة النور', paid: 0, ref: 'F-9');
          buy(supplier: v, supplierName: 'شركة النور', paid: 500);
          await open(tester, RoutePaths.purchases);

          final p1 = find.text(
            '${doc('P-000001')} · ${l10n.purchaseNoSupplier}',
          );
          final p2 = find.text('${doc('P-000002')} · شركة النور');
          final p3 = find.text('${doc('P-000003')} · شركة النور');
          // The list is lazy: at 200% the oldest rows start off screen.
          final list = find.descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          );
          expect(p3, findsOneWidget);
          expect(find.text(l10n.saleKindPartial), findsOneWidget);
          await tester.scrollUntilVisible(p2, 100, scrollable: list);
          expect(tester.getTopLeft(p3).dy, lessThan(tester.getTopLeft(p2).dy));
          expect(find.text(l10n.saleKindCredit), findsOneWidget);
          expect(find.text('F-9'), findsOneWidget);
          await tester.scrollUntilVisible(p1, 100, scrollable: list);
          expect(p1, findsOneWidget);

          await typeIn(tester, field(l10n.purchasesSearchHint), '٢');
          expect(p2, findsOneWidget);
          expect(p1, findsNothing);
          expect(p3, findsNothing);

          await typeIn(tester, field(l10n.purchasesSearchHint), 'f-9');
          expect(p2, findsOneWidget);
          expect(p3, findsNothing);

          await typeIn(tester, field(l10n.purchasesSearchHint), 'النور');
          expect(p2, findsOneWidget);
          expect(p3, findsOneWidget);
          expect(p1, findsNothing);

          await typeIn(tester, field(l10n.purchasesSearchHint), 'زيت');
          expect(find.text(l10n.purchasesNoMatch), findsOneWidget);
        });

        testWidgets('US3-3, US3-4: a purchase shows every line and amount '
            'and is titled a purchase invoice', (tester) async {
          final v = store.seedSupplier('شركة النور');
          final id = buy(
            qty: 3,
            cost: 1000,
            lineDiscount: 500,
            supplier: v,
            supplierName: 'شركة النور',
            paid: 1000,
            ref: 'F-9',
          );
          await open(tester, RoutePaths.purchases);
          await tapVisible(
            tester,
            find.text('${doc('P-000001')} · شركة النور'),
          );
          expect(currentPath(tester), RoutePaths.purchase(id));
          expect(
            find.text(l10n.purchaseTitle(doc('P-000001'))),
            findsOneWidget,
          );
          expect(find.text('شاي'), findsOneWidget);
          expect(
            find.text(
              l10n.invoiceLineDetail(
                ar ? '٣ قطعة' : '3 pc',
                egp('10.00', '١٠٫٠٠'),
              ),
            ),
            findsOneWidget,
          );
          expect(
            find.text(l10n.invoiceLineDiscount(egp('5.00', '٥٫٠٠'))),
            findsOneWidget,
          );
          expect(find.text(egp('25.00', '٢٥٫٠٠')), findsWidgets);
          expect(find.text(egp('15.00', '١٥٫٠٠')), findsOneWidget);
          expect(find.text('F-9'), findsOneWidget);
          expect(find.text(l10n.methodCash), findsOneWidget);
          expect(find.text(doc('2026/10/20')), findsOneWidget);
          expect(find.textContaining('ضريب'), findsNothing);
          expect(
            find.textContaining(RegExp('tax', caseSensitive: false)),
            findsNothing,
          );

          // The supplier opens from the purchase.
          await tapVisible(tester, find.text('شركة النور'));
          expect(currentPath(tester), RoutePaths.supplierDetails(v));
        });

        testWidgets('a missing purchase says so', (tester) async {
          await open(tester, RoutePaths.purchase('nope'));
          expect(find.text(l10n.purchaseNotFound), findsOneWidget);
        });

        testWidgets('US5-1: 120.00 by InstaPay on 300.00 owed: 180.00 left, '
            'PY-000001 in the statement', (tester) async {
          final v = store.seedSupplier('شركة النور', openingPiasters: 30000);
          await open(tester, RoutePaths.supplierDetails(v));
          await tapVisible(tester, find.text(l10n.supplierPayAction));
          expect(currentPath(tester), RoutePaths.supplierPayment(v));
          await typeIn(tester, field(l10n.paymentAmountLabel), '120');
          await tapVisible(tester, find.text(l10n.methodInstapay));
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );
          expect(currentPath(tester), RoutePaths.supplierDetails(v));
          expect(
            find.text(l10n.paymentSaved(doc('PY-000001'))),
            findsOneWidget,
          );
          expect(store.balanceOf(v), 18000);
          final row = find.text(l10n.ledgerPaymentReceipt(doc('PY-000001')));
          await tester.ensureVisible(row);
          expect(row, findsOneWidget);
          expect(find.text(l10n.methodInstapay), findsOneWidget);
          expect(store.statementOf(v).first.method, PaymentMethod.instapay);
        });

        testWidgets('US5-2: an empty or zero amount is blocked', (
          tester,
        ) async {
          final v = store.seedSupplier('شركة النور', openingPiasters: 30000);
          await open(tester, RoutePaths.supplierPayment(v));
          final save = find.widgetWithText(FilledButton, l10n.saveAction);
          await tapVisible(tester, save);
          expect(find.text(l10n.errorAmountRequired), findsOneWidget);
          await typeIn(tester, field(l10n.paymentAmountLabel), '0');
          await tapVisible(tester, save);
          await typeIn(tester, field(l10n.paymentAmountLabel), '1.005');
          await tapVisible(tester, save);
          expect(store.writes, isEmpty);
          expect(currentPath(tester), RoutePaths.supplierPayment(v));
        });

        testWidgets('US5-3: 350.00 on 300.00 owed asks first; the supplier '
            'then owes the shop 50.00', (tester) async {
          final v = store.seedSupplier('شركة النور', openingPiasters: 30000);
          await open(tester, RoutePaths.supplierPayment(v));
          await typeIn(tester, field(l10n.paymentAmountLabel), '350');
          final save = find.widgetWithText(FilledButton, l10n.saveAction);
          await tapVisible(tester, save);
          expect(find.text(l10n.supplierOverpayTitle), findsOneWidget);
          expect(
            find.text(l10n.supplierOverpayBody(egp('50.00', '٥٠٫٠٠'))),
            findsOneWidget,
          );
          await tester.tap(find.text(l10n.backAction));
          await tester.pumpAndSettle();
          expect(store.writes, isEmpty);
          await tapVisible(tester, save);
          await tester.tap(find.text(l10n.confirmAction));
          await tester.pumpAndSettle();
          expect(store.balanceOf(v), -5000);
        });

        testWidgets('US6-1, US6-5: void with a reason: stock back, voided '
            'banner and mark, no second void, out of the unpaid filter', (
          tester,
        ) async {
          final v = store.seedSupplier('شركة النور');
          final id = buy(
            qty: 10,
            supplier: v,
            supplierName: 'شركة النور',
            paid: 0,
          );
          expect(store.products.stockOf(tea), 20000);
          await open(tester, RoutePaths.purchase(id));
          await voidWith(tester, '  سعر خطأ ');
          expect(find.text(l10n.purchaseVoided), findsOneWidget);
          expect(store.products.stockOf(tea), 10000);
          expect(store.balanceOf(v), 0);
          expect(find.textContaining('سعر خطأ'), findsOneWidget);
          expect(find.text(l10n.purchaseVoidAction), findsNothing);
          expect(store.purchase(id)!.voidReason, 'سعر خطأ');

          await goTo(tester, RoutePaths.purchases);
          expect(find.text(l10n.saleVoidedBadge), findsOneWidget);
          await tapVisible(tester, find.text(l10n.salesFilterUnpaid));
          expect(find.text(l10n.purchasesNoMatch), findsOneWidget);
        });

        testWidgets('US6-3: voiding 500.00 with 200.00 paid reverses both '
            'rows; the balance is as before', (tester) async {
          final v = store.seedSupplier('شركة النور', openingPiasters: 1000);
          final id = buy(
            cost: 50000,
            supplier: v,
            supplierName: 'شركة النور',
            paid: 20000,
          );
          expect(store.balanceOf(v), 31000);
          await open(tester, RoutePaths.purchase(id));
          await voidWith(tester, 'مورد خطأ');
          expect(store.balanceOf(v), 1000);
          final types = store.statementOf(v).map((e) => e.type).toList();
          expect(types, contains(SupplierEntryType.purchaseVoid));
          expect(types, contains(SupplierEntryType.reversal));

          await goTo(tester, RoutePaths.supplierDetails(v));
          // The void's message would cover the row.
          tester
              .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
              .clearSnackBars();
          await tester.pumpAndSettle();
          final row = find.text(l10n.ledgerPurchaseVoid(doc('P-000001')));
          await tester.ensureVisible(row);
          expect(row, findsOneWidget);
          // The purchase opens from its statement row.
          await tapVisible(tester, row);
          expect(currentPath(tester), RoutePaths.purchase(id));
        });

        testWidgets('US6-4: an empty or blank reason is blocked', (
          tester,
        ) async {
          final id = buy();
          await open(tester, RoutePaths.purchase(id));
          await voidWith(tester, '   ');
          expect(find.text(l10n.errorReasonRequired), findsOneWidget);
          await tester.tap(find.text(l10n.backAction));
          await tester.pumpAndSettle();
          expect(store.writes, isEmpty);
          expect(store.purchase(id)!.summary.voided, isFalse);
        });

        testWidgets('US6-6: a void that takes stock below zero names the '
            'product; Back voids nothing, confirming voids', (tester) async {
          final id = buy(qty: 10);
          store.products.seedEntry(tea, StockEntryType.sale, -15000);
          expect(store.products.stockOf(tea), 5000);
          await open(tester, RoutePaths.purchase(id));
          await voidWith(tester, 'خطأ');
          expect(find.text(l10n.shortageTitle), findsOneWidget);
          expect(find.textContaining('شاي'), findsWidgets);
          await tester.tap(find.text(l10n.backAction));
          await tester.pumpAndSettle();
          expect(store.writes, isEmpty);
          expect(store.products.stockOf(tea), 5000);

          await voidWith(tester, 'خطأ');
          await tester.tap(find.text(l10n.voidShortageConfirm));
          await tester.pumpAndSettle();
          expect(store.products.stockOf(tea), -5000);
          expect(store.purchase(id)!.summary.voided, isTrue);
        });

        testWidgets('US6-7: a standalone payment is cancelled once with a '
            'reason; the balance goes back up', (tester) async {
          final v = store.seedSupplier('شركة النور', openingPiasters: 30000);
          final request = switch (PaymentRequest.create(
            amountText: '120',
            method: PaymentMethod.cash,
          )) {
            Ok(:final value) => value,
            Err() => throw StateError('invalid payment'),
          };
          await store.suppliers.pay(v, request);
          expect(store.balanceOf(v), 18000);
          await open(tester, RoutePaths.supplierDetails(v));
          await tapVisible(tester, find.text(l10n.paymentCancelAction));
          expect(find.text(l10n.paymentCancelTitle), findsOneWidget);
          await tester.enterText(field(l10n.reasonLabel), 'لم يتم');
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.paymentCancelAction),
          );
          await tester.pumpAndSettle();
          expect(find.text(l10n.paymentCancelled), findsOneWidget);
          expect(store.balanceOf(v), 30000);
          expect(find.text(l10n.ledgerReversal), findsOneWidget);
          expect(find.text(l10n.ledgerCancelled), findsOneWidget);
          expect(find.text(l10n.paymentCancelAction), findsNothing);
        });

        testWidgets('US6-8: a payment made with a purchase has no Cancel', (
          tester,
        ) async {
          final v = store.seedSupplier('شركة النور');
          buy(supplier: v, supplierName: 'شركة النور');
          await open(tester, RoutePaths.supplierDetails(v));
          final row = find.text(l10n.ledgerPurchase(doc('P-000001')));
          await tester.ensureVisible(row);
          expect(row, findsOneWidget);
          expect(find.text(l10n.ledgerPayment), findsOneWidget);
          expect(find.text(l10n.paymentCancelAction), findsNothing);
        });
      });
    }
  }
}

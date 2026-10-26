import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
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
        Future<void> open(
          WidgetTester tester,
          FakePurchasesStore store,
          String path,
        ) async {
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

        Future<void> type(
          WidgetTester tester,
          String label,
          String text,
        ) async {
          final f = find.widgetWithText(TextField, label);
          await tester.ensureVisible(f);
          await tester.enterText(f, text);
          await tester.pump();
        }

        Future<void> save(WidgetTester tester) => tapVisible(
          tester,
          find.widgetWithText(FilledButton, l10n.saveAction),
        );

        /// One unit of a seeded product, bought for [cost].
        PurchaseDraft bought(FakePurchasesStore store, int cost) {
          final tea = store.products.seedProduct('شاي', stockMilli: 1000);
          return const PurchaseDraft().add(
            productId: tea,
            name: 'شاي',
            unit: UnitType.piece,
            salePricePiasters: 1250,
            unitCostPiasters: cost,
          );
        }

        testWidgets('switch to suppliers, add one with a phone (US4-1)', (
          tester,
        ) async {
          final store = FakePurchasesStore();
          await open(tester, store, RoutePaths.parties);
          await tapVisible(tester, find.text(l10n.partiesSuppliersTab));
          expect(currentPath(tester), RoutePaths.suppliers);
          expect(find.text(l10n.suppliersEmptyTitle), findsOneWidget);

          await tapVisible(tester, find.byType(FloatingActionButton));
          expect(currentPath(tester), RoutePaths.supplierNew);
          await type(tester, l10n.supplierNameLabel, 'شركة النور');
          await type(tester, l10n.customerPhoneLabel, '٠٢٢٣٤٥٦٧٨٩');
          await save(tester);
          final id = store.activeSuppliers().single.supplier.id;
          expect(currentPath(tester), RoutePaths.supplierDetails(id));
          expect(store.supplier(id)!.supplier.phone, '0223456789');

          await goTo(tester, RoutePaths.suppliers);
          expect(find.text('شركة النور'), findsOneWidget);
          expect(find.text(l10n.balanceZero), findsOneWidget);
          // And back to customers.
          await tapVisible(tester, find.text(l10n.partiesCustomersTab));
          expect(currentPath(tester), RoutePaths.parties);
          expect(find.text(l10n.customersEmptyTitle), findsOneWidget);
        });

        testWidgets('opening owed by the shop, or in its favour (US4-2)', (
          tester,
        ) async {
          final store = FakePurchasesStore();
          await open(tester, store, RoutePaths.supplierNew);
          await type(tester, l10n.supplierNameLabel, 'شركة النور');
          await type(tester, l10n.customerOpeningAmount, '1000');
          await save(tester);
          expect(
            find.text(l10n.supplierBalanceOwed(egp('1,000.00', '١٬٠٠٠٫٠٠'))),
            findsWidgets,
          );
          await tester.ensureVisible(find.text(l10n.ledgerOpening));
          expect(find.text(l10n.ledgerOpening), findsOneWidget);

          await goTo(tester, RoutePaths.supplierNew);
          await type(tester, l10n.supplierNameLabel, 'مخازن الأمل');
          await type(tester, l10n.customerOpeningAmount, '50');
          await tapVisible(tester, find.text(l10n.supplierOpeningInShopFavour));
          await save(tester);
          expect(
            find.text(l10n.supplierBalanceInShopFavour(egp('50.00', '٥٠٫٠٠'))),
            findsWidgets,
          );
        });

        testWidgets('required name and a bad phone show messages', (
          tester,
        ) async {
          final store = FakePurchasesStore();
          await open(tester, store, RoutePaths.supplierNew);
          await type(tester, l10n.customerPhoneLabel, '12');
          await save(tester);
          expect(find.text(l10n.errorSupplierNameRequired), findsOneWidget);
          expect(
            find.text(l10n.errorPhoneTooShort(ar ? '٧' : '7')),
            findsOneWidget,
          );
          expect(store.writes, isEmpty);
        });

        testWidgets('search by name or phone; owed filter (US4-3, US4-4)', (
          tester,
        ) async {
          final store = FakePurchasesStore()
            ..seedSupplier(
              'شركة النور',
              phone: '0223456789',
              openingPiasters: 100,
            )
            ..seedSupplier('مخازن الأمل', openingPiasters: 900)
            ..seedSupplier('الفجر', openingPiasters: -500);
          await open(tester, store, RoutePaths.suppliers);
          final search = find.widgetWithText(
            TextField,
            l10n.suppliersSearchHint,
          );
          await tester.enterText(search, 'الامل');
          await tester.pumpAndSettle();
          expect(find.text('مخازن الأمل'), findsOneWidget);
          expect(find.text('شركة النور'), findsNothing);
          await tester.enterText(search, '٢٢٣٤');
          await tester.pumpAndSettle();
          expect(find.text('شركة النور'), findsOneWidget);
          expect(find.text('مخازن الأمل'), findsNothing);
          await tester.enterText(search, '');
          await tester.pumpAndSettle();

          await tapVisible(tester, find.text(l10n.suppliersFilterOwed));
          expect(find.text('الفجر'), findsNothing);
          expect(
            tester.getTopLeft(find.text('مخازن الأمل')).dy,
            lessThan(tester.getTopLeft(find.text('شركة النور')).dy),
          );
        });

        testWidgets('statement newest first with numbers (US4-5)', (
          tester,
        ) async {
          final store = FakePurchasesStore();
          final v = store.seedSupplier('شركة النور', openingPiasters: 5000);
          store.seedPurchase(
            bought(store, 4000)
                .withSupplier(PurchaseSupplier(id: v, name: 'شركة النور'))
                .withPaid(0),
          );
          await store.suppliers.pay(
            v,
            const PaymentRequest(
              amountPiasters: 2000,
              method: PaymentMethod.wallet,
            ),
          );
          await open(tester, store, RoutePaths.supplierDetails(v));
          expect(
            find.text(l10n.supplierBalanceOwed(egp('70.00', '٧٠٫٠٠'))),
            findsWidgets,
          );
          final payment = find.text(
            l10n.ledgerPaymentReceipt(doc('PY-000001')),
          );
          final purchase = find.text(l10n.ledgerPurchase(doc('P-000001')));
          final opening = find.text(l10n.ledgerOpening);
          await tester.ensureVisible(opening);
          expect(
            tester.getTopLeft(payment).dy,
            lessThan(tester.getTopLeft(purchase).dy),
          );
          expect(
            tester.getTopLeft(purchase).dy,
            lessThan(tester.getTopLeft(opening).dy),
          );
          expect(find.text(l10n.methodWallet), findsOneWidget);
          // The purchase is listed below the statement too.
          final row = find.textContaining(doc('P-000001'));
          await tester.ensureVisible(row.last);
          expect(row, findsNWidgets(2));
        });

        testWidgets('edit keeps the balance and statement (US4-6)', (
          tester,
        ) async {
          final store = FakePurchasesStore();
          final v = store.seedSupplier('شركة النور', openingPiasters: 700);
          await open(tester, store, RoutePaths.supplierDetails(v));
          await tapVisible(tester, find.text(l10n.productEditAction));
          expect(currentPath(tester), RoutePaths.supplierEdit(v));
          // No opening balance when editing.
          expect(find.text(l10n.customerOpeningAmount), findsNothing);
          await type(tester, l10n.supplierNameLabel, 'النور للتوريدات');
          await save(tester);
          expect(currentPath(tester), RoutePaths.supplierDetails(v));
          expect(find.text('النور للتوريدات'), findsOneWidget);
          expect(store.balanceOf(v), 700);
          expect(store.statementOf(v), hasLength(1));
        });

        testWidgets('archive with a balance asks with it; restore (US4-7)', (
          tester,
        ) async {
          final store = FakePurchasesStore();
          final v = store.seedSupplier('شركة النور', openingPiasters: 6000);
          await open(tester, store, RoutePaths.supplierDetails(v));
          await tapVisible(tester, find.text(l10n.supplierArchiveAction));
          expect(
            find.text(
              l10n.supplierArchiveConfirmBalance(
                l10n.supplierBalanceOwed(egp('60.00', '٦٠٫٠٠')),
              ),
            ),
            findsOneWidget,
          );
          await tester.tap(find.text(l10n.supplierArchiveAction).last);
          await tester.pumpAndSettle();
          expect(find.text(l10n.customerArchivedBadge), findsOneWidget);
          expect(store.activeSuppliers(), isEmpty);
          expect(find.text(l10n.productEditAction), findsNothing);

          await goTo(tester, RoutePaths.suppliersArchived);
          expect(find.text('شركة النور'), findsOneWidget);
          await tapVisible(tester, find.text(l10n.customerRestoreAction));
          expect(find.text(l10n.supplierRestored), findsOneWidget);
          expect(store.activeSuppliers(), hasLength(1));
          expect(store.balanceOf(v), 6000);
        });

        testWidgets('archive with no balance asks plainly', (tester) async {
          final store = FakePurchasesStore();
          final v = store.seedSupplier('شركة النور');
          await open(tester, store, RoutePaths.supplierDetails(v));
          await tapVisible(tester, find.text(l10n.supplierArchiveAction));
          expect(find.text(l10n.supplierArchiveConfirm), findsOneWidget);
          await tapVisible(tester, find.text(l10n.cancelAction));
          expect(store.activeSuppliers(), hasLength(1));
        });

        testWidgets('a missing supplier says so', (tester) async {
          await open(
            tester,
            FakePurchasesStore(),
            RoutePaths.supplierDetails('nope'),
          );
          expect(find.text(l10n.supplierNotFound), findsOneWidget);
        });
      });
    }
  }
}

import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_expenses.dart';
import '../../../helpers/fake_payments.dart';
import '../../../helpers/fake_products.dart';
import '../../../helpers/fake_purchases.dart';
import '../../../helpers/fake_sales.dart';
import '../../../helpers/pump_app.dart';

const _cash300 = PaymentPart(method: PaymentMethod.cash, amountPiasters: 30000);
const _wallet200 = PaymentPart(
  method: PaymentMethod.wallet,
  amountPiasters: 20000,
  accountRef: '01012345678',
);

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    final ar = locale == AppLocale.ar;
    String egp(String latin, String arabic) =>
        ar ? '$arabic ج.م' : 'EGP $latin';

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        late FakeSalesStore sales;
        late FakePurchasesStore buying;
        late FakeExpensesStore spending;
        late FakeAccountSuggestions accounts;

        setUp(() {
          final products = FakeProductsStore();
          sales = FakeSalesStore(products);
          buying = FakePurchasesStore(products);
          spending = FakeExpensesStore();
          accounts = FakeAccountSuggestions();
        });

        Future<void> open(WidgetTester tester, String path) async {
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (!ar) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            products: FakeProductsCubits(sales.products),
            customers: FakeCustomersCubits(sales),
            sales: FakeSalesCubits(sales),
            suppliers: FakeSuppliersCubits(buying),
            purchases: FakePurchasesCubits(buying),
            expenses: FakeExpensesCubits(spending),
            payments: FakePaymentsCubits(accounts),
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

        Future<void> typeIn(WidgetTester tester, Finder f, String text) async {
          await tester.ensureVisible(f);
          await tester.enterText(f, text);
          await tester.pumpAndSettle();
        }

        Finder field(String label) => find.widgetWithText(TextField, label);
        Finder chip(String label) => find.widgetWithText(ChoiceChip, label);
        Finder partAmount(int i) => field(l10n.paymentPartAmountLabel).at(i);

        Future<void> save(WidgetTester tester) => tapVisible(
          tester,
          find.widgetWithText(FilledButton, l10n.saveAction),
        );

        /// Splits 500 into 300 cash and 200 wallet to 01012345678.
        Future<void> split300And200(WidgetTester tester) async {
          await tapVisible(tester, find.text(l10n.paymentSplitAction));
          // Part 1 follows: only part 2 is typed.
          await typeIn(tester, partAmount(1), '٢٠٠');
          expect(find.text(l10n.paymentSplitBalanced), findsOneWidget);
          await typeIn(tester, field(l10n.paymentAccountLabel), '01012345678');
        }

        group('customer payment', () {
          late String mona;

          setUp(() => mona = sales.seedCustomer('منى', openingPiasters: 50000));

          Future<void> openPayment(WidgetTester tester) async {
            await open(tester, RoutePaths.customerPayment(mona));
            await typeIn(tester, field(l10n.paymentAmountLabel), '500');
          }

          LedgerEntry receipt() => sales
              .statementOf(mona)
              .firstWhere((e) => e.type == LedgerEntryType.payment);

          testWidgets('cash shows no account field; wallet shows it and '
              'saves without it (US6-1, 2)', (tester) async {
            await openPayment(tester);
            expect(field(l10n.paymentAccountLabel), findsNothing);
            await tapVisible(tester, chip(l10n.methodWallet));
            expect(field(l10n.paymentAccountLabel), findsOneWidget);
            await save(tester);
            expect(receipt().parts, const [
              PaymentPart(method: PaymentMethod.wallet, amountPiasters: 50000),
            ]);
          });

          testWidgets('a number used before is offered; one tap fills it '
              '(US6-4)', (tester) async {
            accounts.used[PaymentMethod.wallet] = ['01012345678'];
            await openPayment(tester);
            await tapVisible(tester, chip(l10n.methodWallet));
            expect(find.text(l10n.paymentAccountSuggestions), findsOneWidget);
            await tapVisible(
              tester,
              find.widgetWithText(ActionChip, ltrIsolate('01012345678')),
            );
            await save(tester);
            expect(receipt().parts.single.accountRef, '01012345678');
          });

          testWidgets('split 300 cash + 200 wallet; the statement shows both '
              'parts (US6-3)', (tester) async {
            await openPayment(tester);
            await split300And200(tester);
            await save(tester);
            expect(receipt().parts, const [_cash300, _wallet200]);

            await goTo(tester, RoutePaths.customerDetails(mona));
            final cash = l10n.paymentPartLine(
              l10n.methodCash,
              egp('300.00', '٣٠٠٫٠٠'),
            );
            await tester.ensureVisible(find.text(cash));
            expect(find.text(cash), findsOneWidget);
            expect(
              find.text(l10n.paymentPartAccount(ltrIsolate('01012345678'))),
              findsOneWidget,
            );
          });

          testWidgets('parts over the amount are refused with the difference '
              '(US6-5)', (tester) async {
            await openPayment(tester);
            await split300And200(tester);
            await typeIn(tester, partAmount(0), '400');
            expect(
              find.text(l10n.paymentOverBy(egp('100.00', '١٠٠٫٠٠'))),
              findsOneWidget,
            );
            await save(tester);
            final message = l10n.errorPartsOver(egp('100.00', '١٠٠٫٠٠'));
            await tester.ensureVisible(find.text(message));
            expect(find.text(message), findsOneWidget);
            expect(sales.balanceOf(mona), 50000);
          });

          testWidgets('a zero part or a method twice is refused on its part '
              '(US6-6)', (tester) async {
            await openPayment(tester);
            await tapVisible(tester, find.text(l10n.paymentSplitAction));
            await typeIn(tester, partAmount(1), '0');
            await save(tester);
            expect(find.text(l10n.errorPartAmountZero), findsOneWidget);

            await typeIn(tester, partAmount(1), '100');
            await tapVisible(tester, chip(l10n.methodCash).at(1));
            await save(tester);
            expect(find.text(l10n.errorPaymentMethodRepeated), findsOneWidget);
            expect(sales.balanceOf(mona), 50000);

            // Removing part 2 gives one cash part for the whole amount.
            await tapVisible(
              tester,
              find.byTooltip(l10n.paymentPartRemove(ar ? '٢' : '2')),
            );
            expect(field(l10n.paymentPartAmountLabel), findsNothing);
            await save(tester);
            expect(sales.balanceOf(mona), 0);
          });
        });

        testWidgets('new sale split 300 cash + 200 wallet; the invoice shows '
            'each part (US6-3)', (tester) async {
          sales.products.seedProduct(
            'سجادة',
            pricePiasters: 50000,
            stockMilli: 5000,
          );
          await open(tester, RoutePaths.salesNew);
          await tapVisible(tester, find.text(l10n.saleAddProductAction));
          await tester.tap(find.text('سجادة'));
          await tester.pumpAndSettle();
          await split300And200(tester);
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saleSaveAction),
          );
          final summary = sales.salesList(const SaleQuery()).single;
          final SaleInvoice invoice = sales.invoice(summary.id)!;
          expect(invoice.parts, const [_cash300, _wallet200]);

          await goTo(tester, RoutePaths.saleInvoice(summary.id));
          for (final text in [
            l10n.paymentPartLine(l10n.methodCash, egp('300.00', '٣٠٠٫٠٠')),
            l10n.paymentPartLine(l10n.methodWallet, egp('200.00', '٢٠٠٫٠٠')),
            l10n.paymentPartAccount(ltrIsolate('01012345678')),
          ]) {
            await tester.ensureVisible(find.text(text));
            expect(find.text(text), findsOneWidget);
          }
        });

        testWidgets('new purchase paid in two parts', (tester) async {
          sales.products.seedProduct(
            'شاي',
            pricePiasters: 1250,
            stockMilli: 10000,
            costPiasters: 5000,
          );
          await open(tester, RoutePaths.purchasesNew);
          await tapVisible(tester, find.text(l10n.saleAddProductAction));
          await tester.tap(find.text('شاي'));
          await tester.pumpAndSettle();
          await typeIn(tester, field(l10n.purchaseCostLabel), '500');
          await split300And200(tester);
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.purchaseSaveAction),
          );
          final id = buying.purchaseList(const PurchaseQuery()).single.id;
          expect(buying.purchase(id)!.parts, const [_cash300, _wallet200]);
        });

        testWidgets('supplier payment in two parts', (tester) async {
          final nour = buying.seedSupplier('النور', openingPiasters: 50000);
          await open(tester, RoutePaths.supplierPayment(nour));
          await typeIn(tester, field(l10n.paymentAmountLabel), '500');
          await split300And200(tester);
          await save(tester);
          final SupplierEntry row = buying
              .statementOf(nour)
              .firstWhere((e) => e.type == SupplierEntryType.payment);
          expect(row.parts, const [_cash300, _wallet200]);
        });

        testWidgets('expense in two parts; its details show them', (
          tester,
        ) async {
          await open(tester, RoutePaths.expenseNew);
          await tapVisible(tester, chip(l10n.expenseCategoryRent));
          await typeIn(tester, field(l10n.paymentAmountLabel), '500');
          await split300And200(tester);
          await save(tester);
          final e = spending.expenses.single;
          expect(e.parts, const [_cash300, _wallet200]);

          await goTo(tester, RoutePaths.expense(e.id));
          final wallet = l10n.paymentPartLine(
            l10n.methodWallet,
            egp('200.00', '٢٠٠٫٠٠'),
          );
          await tester.ensureVisible(find.text(wallet));
          expect(find.text(wallet), findsOneWidget);
        });
      });
    }
  }
}

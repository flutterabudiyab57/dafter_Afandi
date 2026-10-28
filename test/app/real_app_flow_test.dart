import 'dart:io';

import 'package:daftar_afandi/bootstrap.dart';
import 'package:daftar_afandi/core/database/connection.dart';
import 'package:daftar_afandi/core/di/service_locator.dart';
import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/features/customers/domain/customer_draft.dart';
import 'package:daftar_afandi/features/customers/domain/customer_repository.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:daftar_afandi/features/products/domain/product_repository.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/sales/domain/sales_repository.dart';
import 'package:daftar_afandi/features/settings/domain/app_version.dart';
import 'package:daftar_afandi/features/settings/domain/settings_repository.dart';
import 'package:daftar_afandi/features/settings/domain/shop_profile.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../features/products/data/products_env.dart' show draftOf, okValue;
import '../helpers/pump_app.dart' show currentPath, goTo;

/// The real app end to end (006): bootstrap on a real SQLite file, every
/// real repository and cubit, driven through the screens like the owner
/// would, in Arabic. Covers US1, US2, US3, US4, US5 and US6 together.
void main() {
  final l10n = lookupAppLocalizations(const Locale('ar'));
  String egp(String arabic) => '$arabic ج.م';

  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('daftar_real_flow_');
  });
  tearDown(() async {
    await resetDependencies();
    await dir.delete(recursive: true);
  });

  Future<Widget> start() async {
    final shown = <Widget>[];
    await bootstrap(
      runAppFn: shown.add,
      supportDir: () async => dir,
      executorFactory: (d) => NativeDatabase(File(databasePathIn(d))),
      versionSource: const _FixedVersion(),
    );
    return shown.last;
  }

  testWidgets('a day in the shop', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(420, 900);
    addTearDown(tester.view.reset);

    // First run: onboarding saved, then the app is started again.
    late String mona;
    await tester.runAsync(() async {
      await start();
      await sl<SettingsRepository>().completeOnboarding(
        const ShopProfile(name: 'محل الأمانة'),
      );
      // 500.00 each, 5 in stock, running low at 4.
      okValue(
        await sl<ProductRepository>().create(
          draftOf(
            'سجادة',
            price: '500',
            lowStock: '4',
            openingQty: '5',
            openingCost: '300',
          ),
        ),
      );
      mona = okValue(
        await sl<CustomerRepository>().create(
          okValue(CustomerDraft.create(name: 'منى', openingText: '250')),
        ),
      ).id;
      await resetDependencies();
    });
    final app = (await tester.runAsync(start))!;

    /// Lets the database finish, then settles the frames.
    Future<void> settle() async {
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pumpAndSettle();
      }
    }

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.tap(f);
      await settle();
    }

    Future<void> type(Finder f, String text) async {
      await tester.ensureVisible(f);
      await tester.enterText(f, text);
      await settle();
    }

    Finder field(String label) => find.widgetWithText(TextField, label);

    await tester.pumpWidget(app);
    await settle();
    expect(currentPath(tester), RoutePaths.home);

    // US6 + US4: a sale of one carpet, 300 cash and 200 by wallet to the
    // owner's number; the saved message says the carpet is running low.
    await goTo(tester, RoutePaths.salesNew);
    await settle();
    await tap(find.text(l10n.saleAddProductAction));
    await tap(find.text('سجادة'));
    await tap(find.text(l10n.paymentSplitAction));
    await type(field(l10n.paymentPartAmountLabel).at(1), '٢٠٠');
    expect(find.text(l10n.paymentSplitBalanced), findsOneWidget);
    await type(field(l10n.paymentAccountLabel), '٠١٠١٢٣٤٥٦٧٨');
    await tap(find.widgetWithText(FilledButton, l10n.saleSaveAction));
    final low = l10n.saleLowStockOne('سجادة', '٤ ${l10n.unitPieceShort}');
    expect(find.textContaining(low), findsOneWidget);
    expect(find.text(l10n.saleLowStockShow), findsOneWidget);
    // The message closes by itself.
    await tester.pump(const Duration(seconds: 11));
    await settle();

    // The invoice shows both parts.
    final sale = (await tester.runAsync(
      () => sl<SalesRepository>().watchList(const SaleQuery()).first,
    ))!.single;
    await goTo(tester, RoutePaths.saleInvoice(sale.id));
    await settle();
    for (final text in [
      l10n.paymentPartLine(l10n.methodCash, egp('٣٠٠٫٠٠')),
      l10n.paymentPartLine(l10n.methodWallet, egp('٢٠٠٫٠٠')),
      l10n.paymentPartAccount(ltrIsolate('01012345678')),
    ]) {
      await tester.ensureVisible(find.text(text));
      expect(find.text(text), findsOneWidget);
    }

    // US3: rent of 150.00 in cash.
    await goTo(tester, RoutePaths.expenseNew);
    await settle();
    await tap(find.widgetWithText(ChoiceChip, l10n.expenseCategoryRent));
    await type(field(l10n.paymentAmountLabel), '150');
    await tap(find.widgetWithText(FilledButton, l10n.saveAction));
    expect(currentPath(tester), RoutePaths.expenses);
    await tester.pump(const Duration(seconds: 11));
    await settle();

    // US6-4: Mona pays 250 by wallet; the number used on the sale is
    // offered and one tap fills it.
    await goTo(tester, RoutePaths.customerPayment(mona));
    await settle();
    await type(field(l10n.paymentAmountLabel), '250');
    await tap(find.widgetWithText(ChoiceChip, l10n.methodWallet));
    await tap(find.widgetWithText(ActionChip, ltrIsolate('01012345678')));
    await tap(find.widgetWithText(FilledButton, l10n.saveAction));
    final rows = (await tester.runAsync(
      () => sl<CustomerRepository>().statement(mona),
    ))!;
    expect(
      rows.firstWhere((e) => e.type == LedgerEntryType.payment).parts,
      const [
        PaymentPart(
          method: PaymentMethod.wallet,
          amountPiasters: 25000,
          accountRef: '01012345678',
        ),
      ],
    );

    // US2: profit this month: 500 sales − 300 cost − 150 rent = 50.
    await goTo(tester, RoutePaths.reports);
    await settle();
    expect(find.text(egp('٥٠٠٫٠٠')), findsWidgets);
    expect(find.text(egp('٥٠٫٠٠')), findsOneWidget);

    // US5: money collected: 300 cash, 450 wallet (200 sale + 250 receipt).
    await tap(find.text(l10n.reportCollectedTitle));
    expect(find.text(egp('٣٠٠٫٠٠')), findsOneWidget);
    expect(find.text(egp('٤٥٠٫٠٠')), findsOneWidget);
    expect(find.text(l10n.reportCollectedTotal(egp('٧٥٠٫٠٠'))), findsOneWidget);

    // US5: the carpet tops the sellers.
    await goTo(tester, RoutePaths.reportTopSellers);
    await settle();
    expect(find.text('سجادة'), findsOneWidget);

    // US1: today on the home screen; the carpet counts as running low.
    await goTo(tester, RoutePaths.home);
    await settle();
    expect(find.text(egp('٥٠٠٫٠٠')), findsWidgets);
    expect(tester.takeException(), isNull);

    // Unmount so the database closes cleanly.
    await tester.pumpWidget(const SizedBox.shrink());
    await settle();
  });
}

final class _FixedVersion implements AppVersionSource {
  const _FixedVersion();

  @override
  Future<AppVersion> read() async =>
      const AppVersion(name: '1.0.0', build: '1');
}

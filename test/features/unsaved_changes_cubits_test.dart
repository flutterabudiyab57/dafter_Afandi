import 'package:daftar_afandi/features/customers/presentation/cubits/customer_form_cubit.dart';
import 'package:daftar_afandi/features/customers/presentation/cubits/payment_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/opening_stock_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/product_form_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/stock_adjustment_cubit.dart';
import 'package:daftar_afandi/features/settings/domain/shop_profile.dart';
import 'package:daftar_afandi/features/settings/presentation/cubits/shop_profile_form_cubit.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/supplier_form_cubit.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/supplier_payment_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_products.dart';
import '../helpers/fake_purchases.dart';
import '../helpers/fake_sales.dart';
import '../helpers/pump_app.dart';

/// Every form cubit's `hasUnsavedChanges` (research R9): false when
/// unchanged, true when changed, false when changed back, false once saved.
void main() {
  late FakeProductsStore products;
  late FakeSalesStore sales;
  late FakePurchasesStore purchases;
  late String productId;

  setUp(() {
    products = FakeProductsStore();
    sales = FakeSalesStore(products);
    purchases = FakePurchasesStore(products);
    productId = products.seedProduct('شاي', stockMilli: 5000);
  });

  test('product form, create and edit', () async {
    final create = ProductFormCubit(
      products.products,
      products.categories,
      mode: ProductFormMode.create,
      initialName: 'أرز',
    );
    addTearDown(create.close);
    await pumpEventQueue();
    expect(create.hasUnsavedChanges, isFalse);
    create.priceChanged('10');
    expect(create.hasUnsavedChanges, isTrue);
    create.priceChanged('');
    expect(create.hasUnsavedChanges, isFalse);
    create.priceChanged('10');
    await create.submit();
    expect(create.state.status, ProductFormStatus.saved);
    expect(create.hasUnsavedChanges, isFalse);

    final edit = ProductFormCubit(
      products.products,
      products.categories,
      mode: ProductFormMode.edit,
      productId: productId,
    );
    addTearDown(edit.close);
    await pumpEventQueue();
    expect(edit.state.name, 'شاي');
    expect(edit.hasUnsavedChanges, isFalse);
    edit.nameChanged('شاي أخضر');
    expect(edit.hasUnsavedChanges, isTrue);
    edit.nameChanged('شاي');
    expect(edit.hasUnsavedChanges, isFalse);
  });

  test('opening stock and stock adjustment', () async {
    final opening = OpeningStockCubit(
      products.products,
      products.inventory,
      products.seedProduct('سكر'),
    );
    addTearDown(opening.close);
    await pumpEventQueue();
    expect(opening.hasUnsavedChanges, isFalse);
    opening.qtyChanged('2');
    expect(opening.hasUnsavedChanges, isTrue);
    opening.qtyChanged('');
    expect(opening.hasUnsavedChanges, isFalse);

    final adjust = StockAdjustmentCubit(
      products.products,
      products.inventory,
      productId,
    );
    addTearDown(adjust.close);
    await pumpEventQueue();
    expect(adjust.hasUnsavedChanges, isFalse);
    adjust.qtyChanged('1');
    expect(adjust.hasUnsavedChanges, isTrue);
    adjust.noteChanged('x');
    adjust
      ..qtyChanged('')
      ..noteChanged('');
    expect(adjust.hasUnsavedChanges, isFalse);
  });

  test('customer form and payment', () async {
    final form = CustomerFormCubit(
      sales.customers,
      mode: CustomerFormMode.create,
    );
    addTearDown(form.close);
    expect(form.hasUnsavedChanges, isFalse);
    form.nameChanged('منى');
    expect(form.hasUnsavedChanges, isTrue);
    await form.submit();
    expect(form.state.status, CustomerFormStatus.saved);
    expect(form.hasUnsavedChanges, isFalse);

    final payment = PaymentCubit(sales.customers, sales.seedCustomer('علي'));
    addTearDown(payment.close);
    await pumpEventQueue();
    expect(payment.hasUnsavedChanges, isFalse);
    payment.amountChanged('5');
    expect(payment.hasUnsavedChanges, isTrue);
    payment.amountChanged('');
    expect(payment.hasUnsavedChanges, isFalse);
  });

  test('supplier form and payment', () async {
    final form = SupplierFormCubit(
      purchases.suppliers,
      mode: SupplierFormMode.create,
    );
    addTearDown(form.close);
    expect(form.hasUnsavedChanges, isFalse);
    form.phoneChanged('0101');
    expect(form.hasUnsavedChanges, isTrue);
    form.phoneChanged('');
    expect(form.hasUnsavedChanges, isFalse);

    final payment = SupplierPaymentCubit(
      purchases.suppliers,
      purchases.seedSupplier('النور'),
    );
    addTearDown(payment.close);
    await pumpEventQueue();
    expect(payment.hasUnsavedChanges, isFalse);
    payment.noteChanged('x');
    expect(payment.hasUnsavedChanges, isTrue);
  });

  test('shop profile edit', () async {
    final repo = FakeSettingsRepository(kOnboardedSettings);
    final cubit = ShopProfileFormCubit(
      repo,
      mode: ShopProfileFormMode.settings,
      initial: const ShopProfile(name: 'محل 23', phone: '01012345678'),
    );
    addTearDown(cubit.close);
    expect(cubit.hasUnsavedChanges, isFalse);
    cubit.nameChanged('محل 24');
    expect(cubit.hasUnsavedChanges, isTrue);
    await cubit.submit();
    expect(cubit.state.status, ShopProfileFormStatus.saved);
    expect(cubit.hasUnsavedChanges, isFalse);
  });
}

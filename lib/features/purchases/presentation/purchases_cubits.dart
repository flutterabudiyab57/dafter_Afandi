import 'package:get_it/get_it.dart';

import '../../../core/utils/clock.dart';
import '../../products/domain/category_repository.dart';
import '../../products/domain/product_repository.dart';
import '../../products/presentation/cubits/product_form_cubit.dart';
import '../../products/presentation/cubits/product_picker_cubit.dart';
import '../../suppliers/domain/supplier_repository.dart';
import '../../suppliers/presentation/cubits/supplier_form_cubit.dart';
import '../../suppliers/presentation/cubits/suppliers_list_cubit.dart';
import '../domain/purchase_repository.dart';
import 'cubits/purchase_cubit.dart';
import 'cubits/purchases_list_cubit.dart';

/// Builds every purchases cubit (research R17). The app uses
/// [AppPurchasesCubits]; widget tests pass a bundle built on fakes.
abstract class PurchasesCubits {
  PurchaseCubit purchase();

  ProductPickerCubit productPicker();

  /// The short form that adds a product from the purchase's picker, its
  /// name prefilled (research R13).
  ProductFormCubit quickAddProduct(String name);

  /// The purchase's supplier picker, with quick add.
  SuppliersListCubit supplierPicker();

  /// The full supplier form opened from the picker, its name prefilled.
  SupplierFormCubit newSupplier(String name);

  /// All purchases, or one supplier's when [supplierId] is set.
  PurchasesListCubit purchasesList({String? supplierId});

  PurchaseViewCubit purchaseView(String purchaseId);
}

/// Cubits built on the repositories in [locator].
final class AppPurchasesCubits implements PurchasesCubits {
  const AppPurchasesCubits(this.locator);

  final GetIt locator;

  PurchaseRepository get _purchases => locator<PurchaseRepository>();

  @override
  PurchaseCubit purchase() =>
      PurchaseCubit(_purchases, locator<ProductRepository>(), locator<Clock>());

  @override
  ProductPickerCubit productPicker() =>
      ProductPickerCubit(locator<ProductRepository>());

  @override
  ProductFormCubit quickAddProduct(String name) => ProductFormCubit(
    locator<ProductRepository>(),
    locator<CategoryRepository>(),
    mode: ProductFormMode.create,
    initialName: name,
  );

  @override
  SuppliersListCubit supplierPicker() =>
      SuppliersListCubit(locator<SupplierRepository>());

  @override
  SupplierFormCubit newSupplier(String name) => SupplierFormCubit(
    locator<SupplierRepository>(),
    mode: SupplierFormMode.create,
    initialName: name,
  );

  @override
  PurchasesListCubit purchasesList({String? supplierId}) =>
      PurchasesListCubit(_purchases, supplierId: supplierId);

  @override
  PurchaseViewCubit purchaseView(String purchaseId) =>
      PurchaseViewCubit(_purchases, purchaseId);
}

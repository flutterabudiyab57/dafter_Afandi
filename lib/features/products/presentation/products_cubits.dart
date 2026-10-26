import 'package:get_it/get_it.dart';

import '../domain/category_repository.dart';
import '../domain/inventory_repository.dart';
import '../domain/product_query.dart';
import '../domain/product_repository.dart';
import 'cubits/archived_products_cubit.dart';
import 'cubits/categories_cubit.dart';
import 'cubits/low_stock_cubit.dart';
import 'cubits/opening_stock_cubit.dart';
import 'cubits/product_details_cubit.dart';
import 'cubits/product_form_cubit.dart';
import 'cubits/product_list_cubit.dart';
import 'cubits/stock_adjustment_cubit.dart';
import 'cubits/stock_history_cubit.dart';

/// Builds every products cubit (research R11). The app uses
/// [AppProductsCubits]; widget tests pass a bundle built on fakes.
abstract class ProductsCubits {
  LowStockCubit lowStock();

  ProductListCubit productList({
    ProductQuery initialQuery = const ProductQuery(),
  });

  ProductFormCubit productForm({
    required ProductFormMode mode,
    String? productId,
    String initialName = '',
  });

  ProductDetailsCubit productDetails(String productId);

  StockHistoryCubit stockHistory(String productId);

  OpeningStockCubit openingStock(String productId);

  StockAdjustmentCubit stockAdjustment(String productId);

  CategoriesCubit categories();

  ArchivedProductsCubit archivedProducts();
}

/// Cubits built on the repositories in [locator].
final class AppProductsCubits implements ProductsCubits {
  const AppProductsCubits(this.locator);

  final GetIt locator;

  ProductRepository get _products => locator<ProductRepository>();
  InventoryRepository get _inventory => locator<InventoryRepository>();
  CategoryRepository get _categories => locator<CategoryRepository>();

  @override
  LowStockCubit lowStock() => LowStockCubit(_products);

  @override
  ProductListCubit productList({
    ProductQuery initialQuery = const ProductQuery(),
  }) => ProductListCubit(_products, _categories, initialQuery: initialQuery);

  @override
  ProductFormCubit productForm({
    required ProductFormMode mode,
    String? productId,
    String initialName = '',
  }) => ProductFormCubit(
    _products,
    _categories,
    mode: mode,
    productId: productId,
    initialName: initialName,
  );

  @override
  ProductDetailsCubit productDetails(String productId) =>
      ProductDetailsCubit(_products, productId);

  @override
  StockHistoryCubit stockHistory(String productId) =>
      StockHistoryCubit(_inventory, productId);

  @override
  OpeningStockCubit openingStock(String productId) =>
      OpeningStockCubit(_products, _inventory, productId);

  @override
  StockAdjustmentCubit stockAdjustment(String productId) =>
      StockAdjustmentCubit(_products, _inventory, productId);

  @override
  CategoriesCubit categories() => CategoriesCubit(_categories);

  @override
  ArchivedProductsCubit archivedProducts() => ArchivedProductsCubit(_products);
}

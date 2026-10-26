import 'package:get_it/get_it.dart';

import '../../customers/domain/customer_repository.dart';
import '../../customers/presentation/cubits/customers_list_cubit.dart';
import '../../products/domain/product_repository.dart';
import '../../products/presentation/cubits/product_picker_cubit.dart';
import '../domain/sales_repository.dart';
import 'cubits/sale_cubit.dart';
import 'cubits/sales_list_cubit.dart';

/// Builds every sales cubit (003 research R17). The app uses
/// [AppSalesCubits]; widget tests pass a bundle built on fakes.
abstract class SalesCubits {
  SaleCubit sale();

  ProductPickerCubit productPicker();

  /// The sale's customer picker, with quick add.
  CustomersListCubit customerPicker();

  /// All invoices, or one customer's when [customerId] is set.
  SalesListCubit salesList({String? customerId});

  InvoiceCubit invoice(String invoiceId);
}

/// Cubits built on the repositories in [locator].
final class AppSalesCubits implements SalesCubits {
  const AppSalesCubits(this.locator);

  final GetIt locator;

  SalesRepository get _sales => locator<SalesRepository>();
  ProductRepository get _products => locator<ProductRepository>();

  @override
  SaleCubit sale() => SaleCubit(_sales, _products);

  @override
  ProductPickerCubit productPicker() => ProductPickerCubit(_products);

  @override
  CustomersListCubit customerPicker() =>
      CustomersListCubit(locator<CustomerRepository>());

  @override
  SalesListCubit salesList({String? customerId}) =>
      SalesListCubit(_sales, customerId: customerId);

  @override
  InvoiceCubit invoice(String invoiceId) => InvoiceCubit(_sales, invoiceId);
}

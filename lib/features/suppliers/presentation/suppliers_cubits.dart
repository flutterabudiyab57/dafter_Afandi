import 'package:get_it/get_it.dart';

import '../domain/supplier_repository.dart';
import 'cubits/supplier_details_cubit.dart';
import 'cubits/supplier_form_cubit.dart';
import 'cubits/supplier_payment_cubit.dart';
import 'cubits/suppliers_list_cubit.dart';

/// Builds every suppliers cubit (research R17). The app uses
/// [AppSuppliersCubits]; widget tests pass a bundle built on fakes.
abstract class SuppliersCubits {
  SuppliersListCubit suppliersList();

  SupplierFormCubit supplierForm({
    required SupplierFormMode mode,
    String? supplierId,
    String initialName = '',
  });

  SupplierDetailsCubit supplierDetails(String supplierId);

  SupplierStatementCubit statement(String supplierId);

  SupplierPaymentCubit payment(String supplierId);

  ArchivedSuppliersCubit archivedSuppliers();
}

/// Cubits built on the repositories in [locator].
final class AppSuppliersCubits implements SuppliersCubits {
  const AppSuppliersCubits(this.locator);

  final GetIt locator;

  SupplierRepository get _repo => locator<SupplierRepository>();

  @override
  SuppliersListCubit suppliersList() => SuppliersListCubit(_repo);

  @override
  SupplierFormCubit supplierForm({
    required SupplierFormMode mode,
    String? supplierId,
    String initialName = '',
  }) => SupplierFormCubit(
    _repo,
    mode: mode,
    supplierId: supplierId,
    initialName: initialName,
  );

  @override
  SupplierDetailsCubit supplierDetails(String supplierId) =>
      SupplierDetailsCubit(_repo, supplierId);

  @override
  SupplierStatementCubit statement(String supplierId) =>
      SupplierStatementCubit(_repo, supplierId);

  @override
  SupplierPaymentCubit payment(String supplierId) =>
      SupplierPaymentCubit(_repo, supplierId);

  @override
  ArchivedSuppliersCubit archivedSuppliers() => ArchivedSuppliersCubit(_repo);
}

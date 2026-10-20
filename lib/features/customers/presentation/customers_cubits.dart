import 'package:get_it/get_it.dart';

import '../domain/customer_repository.dart';
import 'cubits/customer_details_cubit.dart';
import 'cubits/customer_form_cubit.dart';
import 'cubits/customers_list_cubit.dart';
import 'cubits/payment_cubit.dart';

/// Builds every customers cubit (003 research R17). The app uses
/// [AppCustomersCubits]; widget tests pass a bundle built on fakes.
abstract class CustomersCubits {
  CustomersListCubit customersList();

  CustomerFormCubit customerForm({
    required CustomerFormMode mode,
    String? customerId,
    String initialName = '',
  });

  CustomerDetailsCubit customerDetails(String customerId);

  StatementCubit statement(String customerId);

  PaymentCubit payment(String customerId);

  ArchivedCustomersCubit archivedCustomers();
}

/// Cubits built on the repositories in [locator].
final class AppCustomersCubits implements CustomersCubits {
  const AppCustomersCubits(this.locator);

  final GetIt locator;

  CustomerRepository get _repo => locator<CustomerRepository>();

  @override
  CustomersListCubit customersList() => CustomersListCubit(_repo);

  @override
  CustomerFormCubit customerForm({
    required CustomerFormMode mode,
    String? customerId,
    String initialName = '',
  }) => CustomerFormCubit(
    _repo,
    mode: mode,
    customerId: customerId,
    initialName: initialName,
  );

  @override
  CustomerDetailsCubit customerDetails(String customerId) =>
      CustomerDetailsCubit(_repo, customerId);

  @override
  StatementCubit statement(String customerId) =>
      StatementCubit(_repo, customerId);

  @override
  PaymentCubit payment(String customerId) => PaymentCubit(_repo, customerId);

  @override
  ArchivedCustomersCubit archivedCustomers() => ArchivedCustomersCubit(_repo);
}

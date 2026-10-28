import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/report_period.dart';
import '../../domain/report_types.dart';
import '../../domain/reports_repository.dart';
import 'report_period_cubit.dart';

final class TopSellersState extends Equatable {
  const TopSellersState({
    required this.period,
    this.order = TopSellerOrder.value,
    this.rows,
    this.loadFailed = false,
  });

  final ReportPeriod period;
  final TopSellerOrder order;

  /// Null while loading.
  final List<TopSeller>? rows;

  /// The stream failed; [TopSellersCubit.retry] tries again.
  final bool loadFailed;

  @override
  List<Object?> get props => [period, order, rows, loadFailed];
}

/// The best-selling products for the chosen period, by value or by
/// quantity (US5, FR-014).
class TopSellersCubit extends Cubit<TopSellersState> {
  TopSellersCubit(this._repository, ReportPeriodCubit periods)
    : super(TopSellersState(period: periods.state)) {
    _periods = periods.stream.listen((period) => _reload(period, state.order));
    _subscribe();
  }

  final ReportsRepository _repository;
  late final StreamSubscription<ReportPeriod> _periods;
  StreamSubscription<List<TopSeller>>? _subscription;

  void retry() => _subscribe();

  void orderBy(TopSellerOrder order) {
    if (order != state.order) _reload(state.period, order);
  }

  void _reload(ReportPeriod period, TopSellerOrder order) {
    emit(TopSellersState(period: period, order: order));
    _subscribe();
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    final TopSellersState(:period, :order) = state;
    if (state.loadFailed) emit(TopSellersState(period: period, order: order));
    _subscription = _repository
        .watchTopSellers(period, order)
        .listen(
          (rows) =>
              emit(TopSellersState(period: period, order: order, rows: rows)),
          onError: (Object error, StackTrace stack) {
            emit(
              TopSellersState(
                period: period,
                order: order,
                rows: state.rows,
                loadFailed: true,
              ),
            );
            addError(error, stack);
          },
        );
  }

  @override
  Future<void> close() async {
    await _periods.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}

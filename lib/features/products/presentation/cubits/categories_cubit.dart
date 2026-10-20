import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/category.dart';
import '../../domain/category_repository.dart';
import '../../domain/product_errors.dart';

final class CategoriesState extends Equatable {
  const CategoriesState({this.categories = const [], this.loaded = false});

  /// Active categories in display order.
  final List<Category> categories;
  final bool loaded;

  @override
  List<Object?> get props => [categories, loaded];
}

/// Categories: add, rename, reorder, archive (FR-017, US5). Writes return
/// their error, if any, for the field or dialog that asked.
class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repository) : super(const CategoriesState()) {
    _subscription = _repository.watchActive().listen(
      (list) => emit(CategoriesState(categories: list, loaded: true)),
      onError: addError,
    );
  }

  final CategoryRepository _repository;
  late final StreamSubscription<List<Category>> _subscription;

  Future<CategoryError?> create(String name) async =>
      _errorOf(await _repository.create(name));

  Future<CategoryError?> rename(String id, String name) async =>
      _errorOf(await _repository.rename(id, name));

  Future<void> archive(String id) => _repository.archive(id);

  Future<void> moveUp(String id) => _repository.move(id, MoveDirection.up);

  Future<void> moveDown(String id) => _repository.move(id, MoveDirection.down);

  static CategoryError? _errorOf<T>(Result<T, CategoryError> r) => switch (r) {
    Ok() => null,
    Err(:final error) => error,
  };

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryState {
  const CategoryState({
    this.isLoading = true,
    this.categories = const [],
    this.error,
  });

  final bool isLoading;
  final List<Category> categories;
  final String? error;

  CategoryState copyWith({
    bool? isLoading,
    List<Category>? categories,
    String? error,
    bool clearError = false,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._repository) : super(const CategoryState()) {
    loadCategories();
  }

  final CategoryRepository _repository;

  Future<void> loadCategories() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(isLoading: false, categories: categories));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }
}

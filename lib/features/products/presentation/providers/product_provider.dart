import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductState {
  const ProductState({
    this.isLoading = true,
    this.products = const [],
    this.error,
  });

  final bool isLoading;
  final List<Product> products;
  final String? error;

  ProductState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? error,
    bool clearError = false,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this._repository) : super(const ProductState()) {
    loadProducts();
  }

  final ProductRepository _repository;

  Future<void> loadProducts({bool forceRefresh = false}) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final products = await _repository.getProducts(
        forceRefresh: forceRefresh,
      );
      emit(state.copyWith(isLoading: false, products: products));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  Future<void> createProduct(Product product) async {
    await _repository.createProduct(product);
    await loadProducts(forceRefresh: true);
  }

  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
    await loadProducts(forceRefresh: true);
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    await loadProducts(forceRefresh: true);
  }
}

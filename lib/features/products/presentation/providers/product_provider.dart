import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRemoteDataSource(apiClient);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource);
});

final productProvider =
    StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
      final repository = ref.watch(productRepositoryProvider);
      return ProductNotifier(repository)..loadProducts();
    });

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductNotifier(this._repository) : super(const AsyncValue.loading());

  final ProductRepository _repository;

  Future<void> loadProducts({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.getProducts(forceRefresh: forceRefresh),
    );
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

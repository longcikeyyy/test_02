import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;
  List<Product>? _cache;

  @override
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      return _cache!;
    }

    final products = await _remoteDataSource.getProducts();
    _cache = products;
    return products;
  }

  @override
  Future<Product> createProduct(Product product) async {
    final created = await _remoteDataSource.createProduct(
      ProductModel(
        id: product.id,
        name: product.name,
        categoryId: product.categoryId,
        currentPrice: product.currentPrice,
        stockQuantity: product.stockQuantity,
      ),
    );
    _cache = null;
    return created;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _remoteDataSource.deleteProduct(id);
    _cache = null;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final updated = await _remoteDataSource.updateProduct(
      ProductModel(
        id: product.id,
        name: product.name,
        categoryId: product.categoryId,
        currentPrice: product.currentPrice,
        stockQuantity: product.stockQuantity,
      ),
    );
    _cache = null;
    return updated;
  }
}

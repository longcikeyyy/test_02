import '../../../../core/network/api_client.dart';
import '../../../../core/utils/api_parser.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProductModel>> getProducts() async {
    final raw = await _apiClient.get(
      '/products',
      queryParameters: {'page': 1, 'size': 100, 'sort': '-CreatedOnDate'},
    );
    final list = parseItemList(raw);
    return list.map(ProductModel.fromJson).toList();
  }

  Future<ProductModel> createProduct(ProductModel model) async {
    final raw = await _apiClient.post('/products', data: model.toUpsertJson());
    return ProductModel.fromJson(parseItem(raw));
  }

  Future<ProductModel> updateProduct(ProductModel model) async {
    final raw = await _apiClient.put(
      '/products/${model.id}',
      data: model.toUpsertJson(),
    );
    return ProductModel.fromJson(parseItem(raw));
  }

  Future<void> deleteProduct(String id) async {
    await _apiClient.delete('/products/$id');
  }
}

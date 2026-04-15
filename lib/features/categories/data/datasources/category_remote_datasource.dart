import '../../../../core/network/api_client.dart';
import '../../../../core/utils/api_parser.dart';
import '../models/category_model.dart';

class CategoryRemoteDataSource {
  CategoryRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CategoryModel>> getCategories() async {
    final raw = await _apiClient.get(
      '/categories',
      queryParameters: {'page': 1, 'size': 100, 'sort': '-CreatedOnDate'},
    );
    final list = parseItemList(raw);
    return list.map(CategoryModel.fromJson).toList();
  }
}

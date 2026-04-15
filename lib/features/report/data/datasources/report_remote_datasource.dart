import '../../../../core/network/api_client.dart';
import '../../../../core/utils/api_parser.dart';
import '../models/sold_product_stat_model.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<SoldProductStatModel>> getSoldProductsStats() async {
    final raw = await _apiClient.get('/orders/statistics/sold-products');
    final list = parseItemList(raw);
    return list.map(SoldProductStatModel.fromJson).toList();
  }
}

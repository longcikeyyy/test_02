import '../../../../core/network/api_client.dart';
import '../../../../core/utils/api_parser.dart';
import '../../domain/entities/order_item_draft.dart';
import '../models/customer_model.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CustomerModel>> getCustomers() async {
    final raw = await _apiClient.get(
      '/customers',
      queryParameters: {'page': 1, 'size': 100, 'sort': '-CreatedOnDate'},
    );
    final list = parseItemList(raw);
    return list.map(CustomerModel.fromJson).toList();
  }

  Future<void> createOrder({
    required String customerId,
    required List<OrderItemDraft> items,
  }) async {
    final orderItems = <Map<String, dynamic>>[];
    for (final item in items) {
      for (var index = 0; index < item.quantity; index++) {
        orderItems.add({
          'orderId': '00000000-0000-0000-0000-000000000000',
          'productId': item.product.id,
        });
      }
    }

    await _apiClient.post(
      '/orders',
      data: {'customerId': customerId, 'items': orderItems},
    );
  }
}

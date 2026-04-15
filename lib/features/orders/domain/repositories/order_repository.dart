import '../entities/customer.dart';
import '../entities/order_item_draft.dart';

abstract class OrderRepository {
  Future<List<Customer>> getCustomers();

  Future<void> createOrder({
    required String customerId,
    required List<OrderItemDraft> items,
  });
}

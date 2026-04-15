import '../../domain/entities/customer.dart';
import '../../domain/entities/order_item_draft.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._remoteDataSource);

  final OrderRemoteDataSource _remoteDataSource;

  @override
  Future<void> createOrder({
    required String customerId,
    required List<OrderItemDraft> items,
  }) {
    return _remoteDataSource.createOrder(customerId: customerId, items: items);
  }

  @override
  Future<List<Customer>> getCustomers() {
    return _remoteDataSource.getCustomers();
  }
}

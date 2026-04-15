import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/order_item_draft.dart';
import '../../domain/repositories/order_repository.dart';

class OrderState {
  const OrderState({
    this.customers = const [],
    this.selectedCustomerId,
    this.quantityByProduct = const {},
    this.isLoadingCustomers = true,
    this.isSubmitting = false,
    this.error,
  });

  final List<Customer> customers;
  final String? selectedCustomerId;
  final Map<String, int> quantityByProduct;
  final bool isLoadingCustomers;
  final bool isSubmitting;
  final String? error;

  OrderState copyWith({
    List<Customer>? customers,
    String? selectedCustomerId,
    Map<String, int>? quantityByProduct,
    bool? isLoadingCustomers,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return OrderState(
      customers: customers ?? this.customers,
      selectedCustomerId: selectedCustomerId ?? this.selectedCustomerId,
      quantityByProduct: quantityByProduct ?? this.quantityByProduct,
      isLoadingCustomers: isLoadingCustomers ?? this.isLoadingCustomers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrderRemoteDataSource(apiClient);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remote = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remote);
});

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderNotifier(ref, repository)..loadCustomers();
});

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier(this._ref, this._repository) : super(const OrderState());

  final Ref _ref;
  final OrderRepository _repository;
  final StreamController<double> _subtotalController =
      StreamController<double>.broadcast();

  Stream<double> get subtotalStream => _subtotalController.stream;

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoadingCustomers: true, clearError: true);
    try {
      final customers = await _repository.getCustomers();
      state = state.copyWith(
        customers: customers,
        selectedCustomerId: customers.isNotEmpty ? customers.first.id : null,
        isLoadingCustomers: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingCustomers: false,
        error: error.toString(),
      );
    }
  }

  void increaseQuantity(Product product) {
    final current = state.quantityByProduct[product.id] ?? 0;
    final updated = Map<String, int>.from(state.quantityByProduct)
      ..[product.id] = current + 1;
    state = state.copyWith(quantityByProduct: updated);
    _emitSubtotal();
  }

  void decreaseQuantity(Product product) {
    final current = state.quantityByProduct[product.id] ?? 0;
    if (current <= 0) {
      return;
    }

    final updated = Map<String, int>.from(state.quantityByProduct);
    if (current == 1) {
      updated.remove(product.id);
    } else {
      updated[product.id] = current - 1;
    }

    state = state.copyWith(quantityByProduct: updated);
    _emitSubtotal();
  }

  void setCustomer(String? customerId) {
    state = state.copyWith(selectedCustomerId: customerId);
  }

  List<OrderItemDraft> buildDraftItems(List<Product> products) {
    final items = <OrderItemDraft>[];
    for (final product in products) {
      final quantity = state.quantityByProduct[product.id] ?? 0;
      if (quantity > 0) {
        items.add(OrderItemDraft(product: product, quantity: quantity));
      }
    }
    return items;
  }

  Future<void> submitOrder(List<Product> products) async {
    final customerId = state.selectedCustomerId;
    if (customerId == null || customerId.isEmpty) {
      throw Exception('Vui long chon khach hang.');
    }

    final items = buildDraftItems(products);
    if (items.isEmpty) {
      throw Exception('Vui long chon it nhat 1 san pham.');
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.createOrder(customerId: customerId, items: items);
      state = state.copyWith(quantityByProduct: {}, isSubmitting: false);
      _emitSubtotal();
    } catch (error) {
      state = state.copyWith(isSubmitting: false, error: error.toString());
      rethrow;
    }
  }

  void _emitSubtotal() {
    final products = _ref.read(productProvider).valueOrNull ?? [];
    final items = buildDraftItems(products);
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
    _subtotalController.add(subtotal);
  }

  @override
  void dispose() {
    _subtotalController.close();
    super.dispose();
  }
}

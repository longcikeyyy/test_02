import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/domain/entities/product.dart';
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

class OrderCubit extends Cubit<OrderState> {
  OrderCubit(this._repository) : super(const OrderState()) {
    loadCustomers();
  }

  final OrderRepository _repository;

  Future<void> loadCustomers() async {
    emit(state.copyWith(isLoadingCustomers: true, clearError: true));
    try {
      final customers = await _repository.getCustomers();
      emit(state.copyWith(
        customers: customers,
        selectedCustomerId: customers.isNotEmpty ? customers.first.id : null,
        isLoadingCustomers: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoadingCustomers: false,
        error: error.toString(),
      ));
    }
  }

  void increaseQuantity(Product product) {
    final current = state.quantityByProduct[product.id] ?? 0;
    final updated = Map<String, int>.from(state.quantityByProduct)
      ..[product.id] = current + 1;
    emit(state.copyWith(quantityByProduct: updated));
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

    emit(state.copyWith(quantityByProduct: updated));
  }

  void setCustomer(String? customerId) {
    emit(state.copyWith(selectedCustomerId: customerId));
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

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _repository.createOrder(customerId: customerId, items: items);
      emit(state.copyWith(quantityByProduct: {}, isSubmitting: false));
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, error: error.toString()));
      rethrow;
    }
  }
}

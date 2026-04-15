import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../providers/order_provider.dart';

class OrderPage extends ConsumerWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    final productsAsync = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(title: Center(child: const Text('Lập đơn hàng'))),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (products) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                initialValue: orderState.selectedCustomerId,
                isExpanded: true,
                items: orderState.customers
                    .map(
                      (customer) => DropdownMenuItem(
                        value: customer.id,
                        child: Text(
                          '${customer.name} (${customer.phoneNumber})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: orderState.isLoadingCustomers
                    ? null
                    : ref.read(orderProvider.notifier).setCustomer,
                decoration: const InputDecoration(
                  labelText: 'Khách hàng',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (_, index) =>
                    _OrderProductTile(product: products[index]),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: products.length,
              ),
            ),
            StreamBuilder<double>(
              stream: ref.read(orderProvider.notifier).subtotalStream,
              initialData: _initialSubtotal(orderState, products),
              builder: (context, snapshot) {
                final subtotal = snapshot.data ?? 0;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng tạm tính: ${formatCurrency(subtotal)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: orderState.isSubmitting
                              ? null
                              : () => _confirmOrder(context, ref, products),
                          child: orderState.isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Xác nhận thanh toán'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _initialSubtotal(OrderState state, List<Product> products) {
    var subtotal = 0.0;
    for (final product in products) {
      final quantity = state.quantityByProduct[product.id] ?? 0;
      subtotal += product.currentPrice * quantity;
    }
    return subtotal;
  }

  Future<void> _confirmOrder(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
  ) async {
    try {
      await ref.read(orderProvider.notifier).submitOrder(products);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tạo đơn hàng thành công.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _OrderProductTile extends ConsumerWidget {
  const _OrderProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    final quantity = orderState.quantityByProduct[product.id] ?? 0;

    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(product.name),
      subtitle: Text(
        '${formatCurrency(product.currentPrice)} | Tồn kho: ${product.stockQuantity}',
      ),
      trailing: SizedBox(
        width: 132,
        child: Row(
          children: [
            IconButton(
              onPressed: quantity <= 0
                  ? null
                  : () => ref
                        .read(orderProvider.notifier)
                        .decreaseQuantity(product),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$quantity'),
            IconButton(
              onPressed: quantity >= product.stockQuantity
                  ? null
                  : () => ref
                        .read(orderProvider.notifier)
                        .increaseQuantity(product),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}

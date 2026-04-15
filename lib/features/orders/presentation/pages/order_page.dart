import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../providers/order_provider.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, productState) {
        if (productState.isLoading) {
          return Scaffold(
            appBar: AppBar(title: Center(child: const Text('Lập đơn hàng'))),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (productState.error != null) {
          return Scaffold(
            appBar: AppBar(title: Center(child: const Text('Lập đơn hàng'))),
            body: Center(child: Text(productState.error!)),
          );
        }

        final products = productState.products;

        return BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderState) {
            final subtotal = _initialSubtotal(orderState, products);
            return Scaffold(
              appBar: AppBar(title: Center(child: const Text('Lập đơn hàng'))),
              body: Column(
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
                          : context.read<OrderCubit>().setCustomer,
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
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
                                : () => _confirmOrder(
                                      context,
                                      products,
                                    ),
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
                  ),
                ],
              ),
            );
          },
        );
      },
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
    List<Product> products,
  ) async {
    try {
      await context.read<OrderCubit>().submitOrder(products);
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

class _OrderProductTile extends StatelessWidget {
  const _OrderProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
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
                      : () => context
                          .read<OrderCubit>()
                          .decreaseQuantity(product),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$quantity'),
                IconButton(
                  onPressed: quantity >= product.stockQuantity
                      ? null
                      : () => context
                          .read<OrderCubit>()
                          .increaseQuantity(product),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/edit_product_dialog.dart';

class ProductManagementPage extends ConsumerWidget {
  const ProductManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Danh sách sản phẩm')),
        actions: [
          IconButton(
            onPressed: () => ref
                .read(productProvider.notifier)
                .loadProducts(forceRefresh: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      body: productState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm nào.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref
                .read(productProvider.notifier)
                .loadProducts(forceRefresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    'Giá: ${formatCurrency(product.currentPrice)} | Tồn kho: ${product.stockQuantity}',
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        onPressed: () =>
                            _showFormDialog(context, ref, product: product),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, ref, product),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: products.length,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showFormDialog(
    BuildContext context,
    WidgetRef ref, {
    Product? product,
  }) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (_) {
        if (product == null) {
          return const AddProductDialog();
        }
        return EditProductDialog(product: product);
      },
    );

    if (result == null || !context.mounted) {
      return;
    }

    try {
      if (product == null) {
        await ref.read(productProvider.notifier).createProduct(result);
      } else {
        await ref.read(productProvider.notifier).updateProduct(result);
      }
      if (!context.mounted) {
        return;
      }
      final message = product == null
          ? 'Thêm sản phẩm thành công'
          : 'Cập nhật sản phẩm thành công';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (accepted != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(productProvider.notifier).deleteProduct(product.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa sản phẩm')));
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

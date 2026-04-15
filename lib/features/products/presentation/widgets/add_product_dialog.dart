import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../categories/presentation/providers/category_provider.dart';
import '../../domain/entities/product.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  const AddProductDialog({super.key});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _stockController = TextEditingController(text: '0');
  String? _selectedCategoryId;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm sản phẩm'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tên sản phẩm không được để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ref
                  .watch(categoryProvider)
                  .when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, _) => Text(error.toString()),
                    data: (categories) {
                      if (categories.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Chưa có danh mục nào.'),
                        );
                      }

                      final hasSelectedCategory = categories.any(
                        (category) => category.id == _selectedCategoryId,
                      );
                      if (_selectedCategoryId == null || !hasSelectedCategory) {
                        _selectedCategoryId = categories.first.id;
                      }

                      return Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 220,
                          child: DropdownButtonFormField<String>(
                            isDense: true,
                            initialValue: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Danh mục',
                              border: OutlineInputBorder(),
                            ),
                            items: categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category.id,
                                    child: Text(
                                      category.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedCategoryId = value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn danh mục';
                              }
                              return null;
                            },
                          ),
                        ),
                      );
                    },
                  ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Giá'),
                validator: (value) {
                  final number = double.tryParse(value ?? '');
                  if (number == null || number < 0) {
                    return 'Giá phải là số >= 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số lượng tồn'),
                validator: (value) {
                  final number = int.tryParse(value ?? '');
                  if (number == null || number < 0) {
                    return 'Số lượng tồn phải >= 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              Product(
                id: _uuid.v4(),
                name: _nameController.text.trim(),
                categoryId: _selectedCategoryId ?? '',
                currentPrice: double.parse(_priceController.text.trim()),
                stockQuantity: int.parse(_stockController.text.trim()),
              ),
            );
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}

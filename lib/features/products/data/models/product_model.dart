import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.currentPrice,
    required super.stockQuantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      categoryId: (json['categoryId'] ?? '').toString(),
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toUpsertJson() {
    return {
      'name': name,
      'categoryId': categoryId,
      'currentPrice': currentPrice,
      'stockQuantity': stockQuantity,
    };
  }
}

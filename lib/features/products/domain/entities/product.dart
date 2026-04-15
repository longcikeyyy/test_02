class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.currentPrice,
    required this.stockQuantity,
  });

  final String id;
  final String name;
  final String categoryId;
  final double currentPrice;
  final int stockQuantity;
}

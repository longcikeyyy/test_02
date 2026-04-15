import '../../../products/domain/entities/product.dart';

class OrderItemDraft {
  const OrderItemDraft({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get total => product.currentPrice * quantity;
}

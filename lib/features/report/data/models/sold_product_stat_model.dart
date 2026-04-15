import '../../domain/entities/sold_product_stat.dart';

class SoldProductStatModel extends SoldProductStat {
  const SoldProductStatModel({
    required super.productId,
    required super.productName,
    required super.quantitySold,
    required super.totalRevenue,
  });

  factory SoldProductStatModel.fromJson(Map<String, dynamic> json) {
    return SoldProductStatModel(
      productId: (json['productId'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      quantitySold: (json['quantitySold'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

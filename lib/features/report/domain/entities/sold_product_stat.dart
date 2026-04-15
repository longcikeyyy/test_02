class SoldProductStat {
  const SoldProductStat({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
  });

  final String productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;
}

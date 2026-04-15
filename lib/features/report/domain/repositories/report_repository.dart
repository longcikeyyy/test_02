import '../entities/sold_product_stat.dart';

abstract class ReportRepository {
  Future<List<SoldProductStat>> getSoldProductsStats();
}

import '../../domain/entities/sold_product_stat.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._remoteDataSource);

  final ReportRemoteDataSource _remoteDataSource;

  @override
  Future<List<SoldProductStat>> getSoldProductsStats() {
    return _remoteDataSource.getSoldProductsStats();
  }
}

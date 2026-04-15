import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/sold_product_stat.dart';
import '../../domain/repositories/report_repository.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReportRemoteDataSource(apiClient);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final remote = ref.watch(reportRemoteDataSourceProvider);
  return ReportRepositoryImpl(remote);
});

final reportProvider =
    StateNotifierProvider<ReportNotifier, AsyncValue<List<SoldProductStat>>>((
      ref,
    ) {
      final repository = ref.watch(reportRepositoryProvider);
      return ReportNotifier(repository)..loadStats();
    });

class ReportNotifier extends StateNotifier<AsyncValue<List<SoldProductStat>>> {
  ReportNotifier(this._repository) : super(const AsyncValue.loading());

  final ReportRepository _repository;

  Future<void> loadStats() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.getSoldProductsStats);
  }
}

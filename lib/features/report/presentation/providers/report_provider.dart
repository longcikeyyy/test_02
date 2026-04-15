import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/sold_product_stat.dart';
import '../../domain/repositories/report_repository.dart';

class ReportState {
  const ReportState({
    this.isLoading = true,
    this.stats = const [],
    this.error,
  });

  final bool isLoading;
  final List<SoldProductStat> stats;
  final String? error;

  ReportState copyWith({
    bool? isLoading,
    List<SoldProductStat>? stats,
    String? error,
    bool clearError = false,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._repository) : super(const ReportState()) {
    loadStats();
  }

  final ReportRepository _repository;

  Future<void> loadStats() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final stats = await _repository.getSoldProductsStats();
      emit(state.copyWith(isLoading: false, stats: stats));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }
}

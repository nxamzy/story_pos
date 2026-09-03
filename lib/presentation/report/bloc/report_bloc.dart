import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/models/expense_model.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/data/repositories/expense_repository.dart';
import 'package:ocam_pos/data/repositories/sale_repository.dart';
import 'package:ocam_pos/presentation/report/bloc/report_event.dart';
import 'package:ocam_pos/presentation/report/bloc/report_state.dart';

/// Kunlik/yillik savdo hisobotlari.
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final SaleRepository _saleRepository;
  final ExpenseRepository _expenseRepository;

  ReportBloc({
    required SaleRepository saleRepository,
    required ExpenseRepository expenseRepository,
  }) : _saleRepository = saleRepository,
       _expenseRepository = expenseRepository,
       super(ReportState()) {
    on<LoadReport>(_onLoad);
    on<SelectReportDate>((event, emit) {
      emit(state.copyWith(selectedDate: event.date));
      add(LoadReport(event.date));
    });
  }

  Future<void> _onLoad(LoadReport event, Emitter<ReportState> emit) async {
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        selectedDate: event.date,
        clearError: true,
      ),
    );

    final dayStart = DateTime(event.date.year, event.date.month, event.date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final yearStart = DateTime(event.date.year, 1, 1);

    try {
      final results = await Future.wait([
        _saleRepository.getSales(from: dayStart, to: dayEnd),
        _saleRepository.getSales(from: yearStart, to: dayEnd),
        _expenseRepository.getExpenses(from: dayStart, to: dayEnd),
      ]);

      final todaySales = results[0] as List<SaleModel>;
      final yearlySales = results[1] as List<SaleModel>;
      final todayExpenses = results[2] as List<ExpenseModel>;
      // Qaytarilgan savdolar yillik summaga ham qo'shilmaydi.
      final yearlyTotal = yearlySales
          .where((sale) => !sale.refunded)
          .fold<double>(0, (sum, s) => sum + s.total);

      emit(
        state.copyWith(
          status: BlocStatus.success,
          todaySales: todaySales,
          todayExpenses: todayExpenses,
          yearlyTotal: yearlyTotal,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          error: Failure.from(error).message,
        ),
      );
    }
  }
}

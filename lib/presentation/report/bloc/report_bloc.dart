import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/models/expense_model.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/data/repositories/expense_repository.dart';
import 'package:ocam_pos/data/repositories/sale_repository.dart';
import 'package:ocam_pos/presentation/report/bloc/report_event.dart';
import 'package:ocam_pos/presentation/report/bloc/report_state.dart';

/// Kunlik/haftalik/oylik savdo hisobotlari.
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
    on<SelectReportDate>(
      (event, emit) => add(LoadReport(event.date, period: state.period)),
    );
    on<SelectReportPeriod>(
      (event, emit) =>
          add(LoadReport(state.selectedDate, period: event.period)),
    );
  }

  /// Davr chegaralari: kun — o'sha kun, hafta — dushanbadan boshlab,
  /// oy — oyning birinchi kunidan.
  ({DateTime start, DateTime end}) _range(DateTime date, ReportPeriod period) {
    final day = DateTime(date.year, date.month, date.day);

    switch (period) {
      case ReportPeriod.day:
        return (start: day, end: day.add(const Duration(days: 1)));
      case ReportPeriod.week:
        final start = day.subtract(Duration(days: day.weekday - 1));
        return (start: start, end: start.add(const Duration(days: 7)));
      case ReportPeriod.month:
        final start = DateTime(date.year, date.month);
        final end = DateTime(date.year, date.month + 1);
        return (start: start, end: end);
    }
  }

  Future<void> _onLoad(LoadReport event, Emitter<ReportState> emit) async {
    final period = event.period ?? state.period;
    final range = _range(event.date, period);
    final yearStart = DateTime(event.date.year, 1, 1);

    emit(
      state.copyWith(
        status: BlocStatus.loading,
        selectedDate: event.date,
        period: period,
        clearError: true,
      ),
    );

    try {
      final results = await Future.wait([
        _saleRepository.getSales(from: range.start, to: range.end),
        _saleRepository.getSales(from: yearStart, to: range.end),
        _expenseRepository.getExpenses(from: range.start, to: range.end),
      ]);

      final sales = results[0] as List<SaleModel>;
      final yearlySales = results[1] as List<SaleModel>;
      final expenses = results[2] as List<ExpenseModel>;

      // Qaytarilgan savdolar yillik summaga ham qo'shilmaydi.
      final yearlyTotal = yearlySales
          .where((sale) => !sale.refunded)
          .fold<double>(0, (sum, s) => sum + s.total);

      emit(
        state.copyWith(
          status: BlocStatus.success,
          sales: sales,
          expenses: expenses,
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

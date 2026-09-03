import 'package:equatable/equatable.dart';
import 'package:ocam_pos/presentation/report/bloc/report_state.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Tanlangan sana va davr bo'yicha hisobotni yuklaydi.
class LoadReport extends ReportEvent {
  final DateTime date;
  final ReportPeriod? period;

  const LoadReport(this.date, {this.period});

  @override
  List<Object?> get props => [date, period];
}

class SelectReportDate extends ReportEvent {
  final DateTime date;
  const SelectReportDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Kun / hafta / oy o'rtasida almashish.
class SelectReportPeriod extends ReportEvent {
  final ReportPeriod period;
  const SelectReportPeriod(this.period);

  @override
  List<Object?> get props => [period];
}

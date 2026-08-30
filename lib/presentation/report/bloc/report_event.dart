import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Tanlangan kunning hisobotini yuklaydi.
class LoadReport extends ReportEvent {
  final DateTime date;
  const LoadReport(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectReportDate extends ReportEvent {
  final DateTime date;
  const SelectReportDate(this.date);

  @override
  List<Object?> get props => [date];
}

import 'package:equatable/equatable.dart';

abstract class RefundsEvent extends Equatable {
  const RefundsEvent();

  @override
  List<Object?> get props => [];
}

/// So'nggi kunlardagi qaytarilgan savdolarni yuklaydi.
class LoadRefunds extends RefundsEvent {
  final int days;
  const LoadRefunds({this.days = 30});

  @override
  List<Object?> get props => [days];
}

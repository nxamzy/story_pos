import 'package:equatable/equatable.dart';

abstract class SalesHistoryEvent extends Equatable {
  const SalesHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Tanlangan davr uchun savdolarni yuklaydi.
class LoadSalesHistory extends SalesHistoryEvent {
  final DateTime from;
  final DateTime to;

  const LoadSalesHistory({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}

/// Ro'yxatni mijoz ismi yoki chek raqami bo'yicha filtrlaydi.
class SearchSalesHistory extends SalesHistoryEvent {
  final String query;
  const SearchSalesHistory(this.query);

  @override
  List<Object?> get props => [query];
}

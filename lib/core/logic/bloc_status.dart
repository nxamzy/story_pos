/// Barcha BLoC state'lari uchun umumiy holat.
///
/// UI shu qiymatga qarab: spinner, ro'yxat yoki xato ekranini ko'rsatadi.
enum BlocStatus { initial, loading, success, failure }

extension BlocStatusX on BlocStatus {
  bool get isInitial => this == BlocStatus.initial;
  bool get isLoading => this == BlocStatus.loading;
  bool get isSuccess => this == BlocStatus.success;
  bool get isFailure => this == BlocStatus.failure;

  /// Birinchi marta yuklanayotgan bo'lsa — to'liq ekranli spinner.
  bool get isFirstLoad => this == BlocStatus.initial || this == BlocStatus.loading;
}

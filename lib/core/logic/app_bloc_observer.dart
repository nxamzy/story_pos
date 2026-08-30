import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Barcha BLoC'lardagi o'zgarish va xatolarni debug rejimda log qiladi.
/// Xatoni qidirganda qaysi bloc qaysi state'ga o'tganini ko'rsatadi.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint(
        '[${bloc.runtimeType}] ${transition.event.runtimeType} '
        '-> ${transition.nextState.runtimeType}',
      );
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[${bloc.runtimeType}] XATO: $error');
    }
    super.onError(bloc, error, stackTrace);
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/repositories/product_repository.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_event.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_state.dart';

/// Ombor (inventarizatsiya) mantiqi.
///
/// Ma'lumot stream orqali keladi — mahsulot qo'shilsa yoki sotilsa,
/// ro'yxat o'zi yangilanadi, qo'lda qayta yuklash shart emas.
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;
  StreamSubscription<List<ProductModel>>? _subscription;

  ProductBloc({required ProductRepository repository})
    : _repository = repository,
      super(const ProductState()) {
    on<LoadProducts>(_onLoad);
    on<ProductsUpdated>(_onUpdated);
    on<ProductsFailed>(_onFailed);
    on<AddProduct>(_onAdd);
    on<UpdateProduct>(_onUpdate);
    on<DeleteProduct>(_onDelete);
    on<SearchProducts>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
    on<FilterProductsByCategory>(
      (event, emit) => emit(state.copyWith(category: event.category)),
    );
  }

  void _onLoad(LoadProducts event, Emitter<ProductState> emit) {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    _subscription?.cancel();
    _subscription = _repository.watchProducts().listen(
      (products) => add(ProductsUpdated(products)),
      onError: (Object error) => add(ProductsFailed(Failure.from(error).message)),
    );
  }

  void _onUpdated(ProductsUpdated event, Emitter<ProductState> emit) {
    emit(
      state.copyWith(
        status: BlocStatus.success,
        products: event.products,
        clearError: true,
      ),
    );
  }

  void _onFailed(ProductsFailed event, Emitter<ProductState> emit) {
    emit(state.copyWith(status: BlocStatus.failure, error: event.message));
  }

  Future<void> _onAdd(AddProduct event, Emitter<ProductState> emit) async {
    try {
      await _repository.addProduct(event.product);
      emit(state.copyWith(actionMessage: "Mahsulot qo'shildi"));
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  Future<void> _onUpdate(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _repository.updateProduct(event.product);
      emit(state.copyWith(actionMessage: "Mahsulot yangilandi"));
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  Future<void> _onDelete(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _repository.deleteProduct(event.id);
      emit(state.copyWith(actionMessage: "Mahsulot o'chirildi"));
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

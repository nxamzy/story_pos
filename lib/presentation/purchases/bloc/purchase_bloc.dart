import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/models/purchase_model.dart';
import 'package:ocam_pos/data/repositories/purchase_repository.dart';
import 'package:ocam_pos/presentation/purchases/bloc/purchase_event.dart';
import 'package:ocam_pos/presentation/purchases/bloc/purchase_state.dart';

/// Ta'minotchidan mahsulot kirimi (xarid).
///
/// Savdodagi savat kabi bu yerda ham "qoralama" bor: ta'minotchi tanlanadi,
/// mahsulotlar miqdori va tannarxi bilan qo'shiladi, so'ng bitta
/// tranzaksiyada omborga kiritiladi.
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PurchaseRepository _repository;
  StreamSubscription<List<PurchaseModel>>? _subscription;

  PurchaseBloc({required PurchaseRepository repository})
    : _repository = repository,
      super(const PurchaseState()) {
    on<LoadPurchases>(_onLoad);
    on<PurchasesUpdated>(
      (event, emit) => emit(
        state.copyWith(
          status: BlocStatus.success,
          purchases: event.purchases,
          clearError: true,
        ),
      ),
    );
    on<PurchasesFailed>(
      (event, emit) => emit(
        state.copyWith(status: BlocStatus.failure, error: event.message),
      ),
    );
    on<SelectPurchaseSupplier>(
      (event, emit) => emit(
        state.copyWith(
          supplier: event.supplier,
          clearSupplier: event.supplier == null,
          clearError: true,
        ),
      ),
    );
    on<AddPurchaseItem>(_onAddItem);
    on<UpdatePurchaseItem>(_onUpdateItem);
    on<RemovePurchaseItem>(
      (event, emit) => emit(
        state.copyWith(
          draftItems: state.draftItems
              .where((item) => item.productId != event.productId)
              .toList(),
          clearError: true,
        ),
      ),
    );
    on<SetPurchasePaidFromDrawer>(
      (event, emit) =>
          emit(state.copyWith(paidFromDrawer: event.paidFromDrawer)),
    );
    on<SubmitPurchase>(_onSubmit);
    on<ClearPurchaseDraft>(
      (event, emit) => emit(
        state.copyWith(
          draftItems: const [],
          clearSupplier: true,
          paidFromDrawer: true,
          clearError: true,
        ),
      ),
    );
    on<PurchaseMessageCleared>(
      (event, emit) => emit(state.copyWith(clearError: true)),
    );
  }

  void _onLoad(LoadPurchases event, Emitter<PurchaseState> emit) {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    _subscription?.cancel();
    _subscription = _repository.watchPurchases().listen(
      (purchases) => add(PurchasesUpdated(purchases)),
      onError: (Object e) => add(PurchasesFailed(Failure.from(e).message)),
    );
  }

  void _onAddItem(AddPurchaseItem event, Emitter<PurchaseState> emit) {
    final items = List<PurchaseItem>.from(state.draftItems);
    final index = items.indexWhere(
      (item) => item.productId == event.product.id,
    );

    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + 1,
      );
    } else {
      items.add(PurchaseItem.fromProduct(event.product));
    }

    emit(state.copyWith(draftItems: items, clearError: true));
  }

  void _onUpdateItem(UpdatePurchaseItem event, Emitter<PurchaseState> emit) {
    final items = List<PurchaseItem>.from(state.draftItems);
    final index = items.indexWhere((item) => item.productId == event.productId);
    if (index < 0) return;

    final quantity = event.quantity;
    if (quantity != null && quantity <= 0) {
      items.removeAt(index);
      emit(state.copyWith(draftItems: items, clearError: true));
      return;
    }

    items[index] = items[index].copyWith(
      quantity: quantity,
      buyPrice: event.buyPrice,
    );
    emit(state.copyWith(draftItems: items, clearError: true));
  }

  Future<void> _onSubmit(
    SubmitPurchase event,
    Emitter<PurchaseState> emit,
  ) async {
    if (state.supplier == null) {
      emit(state.copyWith(error: "Ta'minotchini tanlang"));
      return;
    }
    if (state.draftItems.isEmpty) {
      emit(state.copyWith(error: "Kamida bitta mahsulot qo'shing"));
      return;
    }

    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      final id = await _repository.createPurchase(
        PurchaseModel(
          id: '',
          supplierId: state.supplier!.id,
          supplierName: state.supplier!.name,
          items: state.draftItems,
          note: event.note,
          paidFromDrawer: state.paidFromDrawer,
          createdAt: DateTime.now(),
        ),
      );

      emit(
        state.copyWith(
          isSaving: false,
          draftItems: const [],
          clearSupplier: true,
          paidFromDrawer: true,
          savedPurchaseId: id,
          actionMessage: "Xarid saqlandi, ombor to'ldirildi",
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(isSaving: false, error: Failure.from(error).message),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

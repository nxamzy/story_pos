import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';
import 'package:ocam_pos/data/repositories/supplier_repository.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_event.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_state.dart';

/// Taminotchilar bilan ishlash mantiqi.
/// Ilgari bu mantiq to'g'ridan-to'g'ri ekran ichida edi — endi shu yerda.
class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierRepository _repository;
  StreamSubscription<List<SupplierModel>>? _subscription;

  SupplierBloc({required SupplierRepository repository})
    : _repository = repository,
      super(const SupplierState()) {
    on<LoadSuppliers>(_onLoad);
    on<SuppliersUpdated>(
      (event, emit) => emit(
        state.copyWith(
          status: BlocStatus.success,
          suppliers: event.suppliers,
          clearError: true,
        ),
      ),
    );
    on<SuppliersFailed>(
      (event, emit) => emit(
        state.copyWith(status: BlocStatus.failure, error: event.message),
      ),
    );
    on<AddSupplier>(_onAdd);
    on<UpdateSupplier>(_onUpdate);
    on<DeleteSupplier>(_onDelete);
    on<SearchSuppliers>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
  }

  void _onLoad(LoadSuppliers event, Emitter<SupplierState> emit) {
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        filterDate: event.date,
        clearDate: event.date == null,
        clearError: true,
      ),
    );
    _subscription?.cancel();
    _subscription = _repository.watchSuppliers(date: event.date).listen(
      (suppliers) => add(SuppliersUpdated(suppliers)),
      onError: (Object e) => add(SuppliersFailed(Failure.from(e).message)),
    );
  }

  Future<void> _onAdd(AddSupplier event, Emitter<SupplierState> emit) async {
    final validation = _validate(event.supplier);
    if (validation != null) {
      emit(state.copyWith(error: validation));
      return;
    }
    try {
      await _repository.addSupplier(event.supplier);
      emit(
        state.copyWith(
          actionMessage: "Taminotchi qo'shildi",
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  Future<void> _onUpdate(
    UpdateSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    final validation = _validate(event.supplier);
    if (validation != null) {
      emit(state.copyWith(error: validation));
      return;
    }
    try {
      await _repository.updateSupplier(event.supplier);
      emit(
        state.copyWith(actionMessage: "Ma'lumot yangilandi", clearError: true),
      );
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  Future<void> _onDelete(
    DeleteSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    try {
      await _repository.deleteSupplier(event.id);
      emit(
        state.copyWith(actionMessage: "Taminotchi o'chirildi", clearError: true),
      );
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  String? _validate(SupplierModel supplier) {
    if (supplier.name.trim().isEmpty) return "Taminotchi nomini kiriting";
    if (supplier.phone.trim().isEmpty) return "Telefon raqamni kiriting";
    return null;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/purchase_model.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';

class PurchaseState extends Equatable {
  final BlocStatus status;
  final List<PurchaseModel> purchases;

  // --- Yangi xarid qoralamasi ---
  final SupplierModel? supplier;
  final List<PurchaseItem> draftItems;
  final bool paidFromDrawer;
  final bool isSaving;

  /// Saqlangan xarid id'si — forma shu belgiga qarab yopiladi.
  final String? savedPurchaseId;

  final String? error;
  final String? actionMessage;

  const PurchaseState({
    this.status = BlocStatus.initial,
    this.purchases = const [],
    this.supplier,
    this.draftItems = const [],
    this.paidFromDrawer = true,
    this.isSaving = false,
    this.savedPurchaseId,
    this.error,
    this.actionMessage,
  });

  double get draftTotal =>
      draftItems.fold(0, (sum, item) => sum + item.subTotal);

  int get draftQuantity =>
      draftItems.fold(0, (sum, item) => sum + item.quantity);

  bool get canSubmit => draftItems.isNotEmpty && supplier != null;

  PurchaseState copyWith({
    BlocStatus? status,
    List<PurchaseModel>? purchases,
    SupplierModel? supplier,
    List<PurchaseItem>? draftItems,
    bool? paidFromDrawer,
    bool? isSaving,
    String? savedPurchaseId,
    String? error,
    String? actionMessage,
    bool clearError = false,
    bool clearSupplier = false,
  }) {
    return PurchaseState(
      status: status ?? this.status,
      purchases: purchases ?? this.purchases,
      supplier: clearSupplier ? null : (supplier ?? this.supplier),
      draftItems: draftItems ?? this.draftItems,
      paidFromDrawer: paidFromDrawer ?? this.paidFromDrawer,
      isSaving: isSaving ?? this.isSaving,
      // Bir martalik qiymatlar — keyingi holatda o'zi tozalanadi.
      savedPurchaseId: savedPurchaseId,
      error: clearError ? null : (error ?? this.error),
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    purchases,
    supplier,
    draftItems,
    paidFromDrawer,
    isSaving,
    savedPurchaseId,
    error,
    actionMessage,
  ];
}

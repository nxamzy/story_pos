import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/models/purchase_model.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';

abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

/// Xaridlar tarixini kuzatishni boshlaydi.
class LoadPurchases extends PurchaseEvent {
  const LoadPurchases();
}

class PurchasesUpdated extends PurchaseEvent {
  final List<PurchaseModel> purchases;
  const PurchasesUpdated(this.purchases);

  @override
  List<Object?> get props => [purchases];
}

class PurchasesFailed extends PurchaseEvent {
  final String message;
  const PurchasesFailed(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Yangi xarid qoralamasi (draft) ---

class SelectPurchaseSupplier extends PurchaseEvent {
  final SupplierModel? supplier;
  const SelectPurchaseSupplier(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

/// Qoralamaga mahsulot qo'shadi (bor bo'lsa miqdorini oshiradi).
class AddPurchaseItem extends PurchaseEvent {
  final ProductModel product;
  const AddPurchaseItem(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdatePurchaseItem extends PurchaseEvent {
  final String productId;
  final int? quantity;
  final double? buyPrice;

  const UpdatePurchaseItem(this.productId, {this.quantity, this.buyPrice});

  @override
  List<Object?> get props => [productId, quantity, buyPrice];
}

class RemovePurchaseItem extends PurchaseEvent {
  final String productId;
  const RemovePurchaseItem(this.productId);

  @override
  List<Object?> get props => [productId];
}

class SetPurchasePaidFromDrawer extends PurchaseEvent {
  final bool paidFromDrawer;
  const SetPurchasePaidFromDrawer(this.paidFromDrawer);

  @override
  List<Object?> get props => [paidFromDrawer];
}

/// Qoralamani saqlaydi: ombor to'ldiriladi, tannarx yangilanadi.
class SubmitPurchase extends PurchaseEvent {
  final String note;
  const SubmitPurchase({this.note = ''});

  @override
  List<Object?> get props => [note];
}

/// Qoralamani tozalaydi (saqlangandan keyin yoki bekor qilinganda).
class ClearPurchaseDraft extends PurchaseEvent {
  const ClearPurchaseDraft();
}

class PurchaseMessageCleared extends PurchaseEvent {
  const PurchaseMessageCleared();
}

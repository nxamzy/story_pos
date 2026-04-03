import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/models/cart_item_model.dart';

abstract class BillingEvent {}

class LoadAllProductsEvent extends BillingEvent {
  final String userId;
  LoadAllProductsEvent(this.userId);
}

class ConfirmSaleEvent extends BillingEvent {
  final String userId;
  ConfirmSaleEvent(this.userId);
}

class FilterProductsByCategoryEvent extends BillingEvent {
  final String category;
  FilterProductsByCategoryEvent(this.category);
}

class ScanBarcodeEvent extends BillingEvent {
  final String barcode;
  ScanBarcodeEvent(this.barcode);
}

class AddProductToCartEvent extends BillingEvent {
  final ProductModel product;
  AddProductToCartEvent(this.product);
}

class UpdateQuantityEvent extends BillingEvent {
  final String productId;
  final int quantity;
  UpdateQuantityEvent(this.productId, this.quantity);
}

class ClearCartEvent extends BillingEvent {}

class CompleteSaleEvent extends BillingEvent {
  final double amountPaid;
  final bool printReceipt;
  final String? note;

  CompleteSaleEvent({
    required this.amountPaid,
    required this.printReceipt,
    this.note,
  });
}

// --- 📊 STATE ---
class BillingState {
  final List<CartItem> cartItems;
  final List<ProductModel> products;
  final double totalAmount;
  final String? error;
  final bool isLoading;
  final bool saleSuccess;

  BillingState({
    this.cartItems = const [],
    this.products = const [],
    this.totalAmount = 0.0,
    this.error,
    this.isLoading = false,
    this.saleSuccess = false,
  });

  BillingState copyWith({
    List<CartItem>? cartItems,
    List<ProductModel>? products,
    double? totalAmount,
    String? error,
    bool? isLoading,
    bool? saleSuccess,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      products: products ?? this.products,
      totalAmount: totalAmount ?? this.totalAmount,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      saleSuccess: saleSuccess ?? false,
    );
  }
}

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BillingBloc() : super(BillingState()) {
    on<ConfirmSaleEvent>((event, emit) async {
      if (state.cartItems.isEmpty) return;

      emit(state.copyWith(isLoading: true, saleSuccess: false));

      try {
        final batch = _firestore.batch();

        for (var cartItem in state.cartItems) {
          final productRef = _firestore
              .collection('products')
              .doc(cartItem.product.id);

          batch.update(productRef, {
            'stock': FieldValue.increment(-cartItem.quantity),
          });
        }

        await batch.commit();

        await _firestore.collection('sales').add({
          'userId': event.userId,
          'items': state.cartItems.map((e) => e.toMap()).toList(),
          'totalAmount': state.totalAmount,
          'timestamp': FieldValue.serverTimestamp(),
        });

        emit(
          state.copyWith(
            cartItems: [],
            totalAmount: 0.0,
            isLoading: false,
            saleSuccess: true,
            error: "Sotuv muvaffaqiyatli yakunlandi va stok yangilandi!",
          ),
        );

        add(LoadAllProductsEvent(event.userId));
      } catch (e) {
        emit(
          state.copyWith(
            isLoading: false,
            error: "Xatolik: $e",
            saleSuccess: false,
          ),
        );
      }
    });

    on<LoadAllProductsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null, saleSuccess: false));
      try {
        final querySnapshot = await _firestore
            .collection('products')
            .where('userId', isEqualTo: event.userId)
            .get();

        final products = querySnapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList();

        emit(state.copyWith(products: products, isLoading: false));
      } catch (e) {
        emit(state.copyWith(error: "Yuklashda xatolik: $e", isLoading: false));
      }
    });

    on<ScanBarcodeEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

        final querySnapshot = await _firestore
            .collection('products')
            .where('barcode', isEqualTo: event.barcode)
            .where('userId', isEqualTo: currentUserId)
            .get();

        if (querySnapshot.docs.isEmpty) {
          emit(state.copyWith(error: "Mahsulot topilmadi!", isLoading: false));
          return;
        }

        final doc = querySnapshot.docs.first;
        final product = ProductModel.fromMap(doc.data(), doc.id);
        add(AddProductToCartEvent(product));
        emit(state.copyWith(isLoading: false));
      } catch (e) {
        emit(state.copyWith(error: "Xatolik: $e", isLoading: false));
      }
    });

    on<AddProductToCartEvent>((event, emit) {
      List<CartItem> newList = List.from(state.cartItems);
      int index = newList.indexWhere(
        (item) => item.product.id == event.product.id,
      );

      if (index >= 0) {
        newList[index] = newList[index].copyWith(
          quantity: newList[index].quantity + 1,
        );
      } else {
        newList.add(CartItem(product: event.product));
      }

      emit(
        state.copyWith(
          cartItems: newList,
          totalAmount: _calculateTotal(newList),
          saleSuccess: false,
        ),
      );
    });

    on<UpdateQuantityEvent>((event, emit) {
      List<CartItem> newList = List.from(state.cartItems);
      int index = newList.indexWhere(
        (item) => item.product.id == event.productId,
      );

      if (index >= 0) {
        if (event.quantity <= 0) {
          newList.removeAt(index);
        } else {
          newList[index] = newList[index].copyWith(quantity: event.quantity);
        }
        emit(
          state.copyWith(
            cartItems: newList,
            totalAmount: _calculateTotal(newList),
            saleSuccess: false,
          ),
        );
      }
    });

    on<FilterProductsByCategoryEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
        Query query = _firestore
            .collection('products')
            .where('userId', isEqualTo: currentUserId);

        if (event.category != "All") {
          query = query.where('category', isEqualTo: event.category);
        }

        final snapshot = await query.get();

        // 🔥 MANA BU YERDA TO'G'IRLANDI:
        final products = snapshot.docs.map((doc) {
          // doc.data() ni Map sifatida kasting qilamiz
          final data = doc.data() as Map<String, dynamic>;
          return ProductModel.fromMap(data, doc.id);
        }).toList();

        emit(
          state.copyWith(
            products: products,
            isLoading: false,
            saleSuccess: false,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(isLoading: false, error: "Filtrlashda xatolik: $e"),
        );
      }
    });
    on<ClearCartEvent>(
      (event, emit) => emit(
        state.copyWith(cartItems: [], totalAmount: 0.0, saleSuccess: false),
      ),
    );

    on<CompleteSaleEvent>((event, emit) async {
      if (state.cartItems.isEmpty) return;

      emit(state.copyWith(isLoading: true, error: null, saleSuccess: false));
      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

        await _firestore.collection('sales').add({
          'userId': currentUserId,
          'items': state.cartItems.map((item) => item.toMap()).toList(),
          'total': state.totalAmount,
          'paid': event.amountPaid,
          'change': event.amountPaid - state.totalAmount,
          'note': event.note ?? "",
          'date': FieldValue.serverTimestamp(),
        });

        emit(
          state.copyWith(
            cartItems: [],
            totalAmount: 0.0,
            isLoading: false,
            saleSuccess: true,
          ),
        );

        add(LoadAllProductsEvent(currentUserId));
      } catch (e) {
        emit(state.copyWith(error: "Sotuvda xatolik: $e", isLoading: false));
      }
    });
  }

  double _calculateTotal(List<CartItem> items) =>
      items.fold(0.0, (sum, item) => sum + item.subTotal);
}

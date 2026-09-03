import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/models/cart_item_model.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/data/repositories/product_repository.dart';
import 'package:ocam_pos/data/repositories/sale_repository.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_event.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_state.dart';

/// Savdo (kassa) mantiqi: mahsulot tanlash, savat va to'lov.
class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final ProductRepository _productRepository;
  final SaleRepository _saleRepository;
  StreamSubscription<List<ProductModel>>? _subscription;

  SaleBloc({
    required ProductRepository productRepository,
    required SaleRepository saleRepository,
  }) : _productRepository = productRepository,
       _saleRepository = saleRepository,
       super(const SaleState()) {
    on<LoadSaleProducts>(_onLoad);
    on<SaleProductsUpdated>(
      (event, emit) => emit(
        state.copyWith(
          status: BlocStatus.success,
          products: event.products,
          clearError: true,
        ),
      ),
    );
    on<SaleProductsFailed>(
      (event, emit) => emit(
        state.copyWith(status: BlocStatus.failure, error: event.message),
      ),
    );
    on<SearchSaleProducts>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
    on<FilterSaleByCategory>(
      (event, emit) => emit(state.copyWith(category: event.category)),
    );
    on<ScanBarcodeEvent>(_onScan);
    on<AddProductToCartEvent>(_onAddToCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<RemoveFromCartEvent>(_onRemove);
    on<ClearCartEvent>(
      (event, emit) => emit(
        state.copyWith(
          cartItems: const [],
          clearCustomer: true,
          clearError: true,
        ),
      ),
    );
    on<SelectSaleCustomerEvent>(
      (event, emit) => emit(
        state.copyWith(
          customer: event.customer,
          clearCustomer: event.customer == null,
        ),
      ),
    );
    on<SelectPaymentMethodEvent>(
      (event, emit) => emit(state.copyWith(paymentMethod: event.method)),
    );
    on<CompleteSaleEvent>(_onComplete);
    on<RefundSaleEvent>(_onRefund);
    on<SaleMessageCleared>(
      (event, emit) => emit(state.copyWith(clearError: true)),
    );
  }

  void _onLoad(LoadSaleProducts event, Emitter<SaleState> emit) {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    _subscription?.cancel();
    _subscription = _productRepository.watchProducts().listen(
      (products) => add(SaleProductsUpdated(products)),
      onError: (Object e) => add(SaleProductsFailed(Failure.from(e).message)),
    );
  }

  Future<void> _onScan(ScanBarcodeEvent event, Emitter<SaleState> emit) async {
    final barcode = event.barcode.trim();
    if (barcode.isEmpty) return;

    try {
      final product = await _productRepository.findByBarcode(barcode);
      if (product == null) {
        emit(state.copyWith(error: "Bu shtrix-kod bo'yicha mahsulot topilmadi"));
        return;
      }
      add(AddProductToCartEvent(product));
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  void _onAddToCart(AddProductToCartEvent event, Emitter<SaleState> emit) {
    final product = event.product;
    final items = List<CartItem>.from(state.cartItems);
    final index = items.indexWhere((item) => item.product.id == product.id);
    final currentQuantity = index >= 0 ? items[index].quantity : 0;

    // Omborda yo'q mahsulotni savatga qo'shishning oldi olinadi —
    // ilgari savat cheksiz to'lib, to'lov paytida xato chiqardi.
    if (product.stock <= currentQuantity) {
      emit(
        state.copyWith(
          error: product.stock <= 0
              ? "«${product.name}» omborda tugagan"
              : "«${product.name}» dan faqat ${product.stock} ta qolgan",
        ),
      );
      return;
    }

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: currentQuantity + 1);
    } else {
      items.add(CartItem(product: product));
    }

    emit(state.copyWith(cartItems: items, clearError: true));
  }

  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<SaleState> emit) {
    final items = List<CartItem>.from(state.cartItems);
    final index = items.indexWhere(
      (item) => item.product.id == event.productId,
    );
    if (index < 0) return;

    if (event.quantity <= 0) {
      items.removeAt(index);
      emit(state.copyWith(cartItems: items, clearError: true));
      return;
    }

    final stock = items[index].product.stock;
    if (event.quantity > stock) {
      emit(state.copyWith(error: "Omborda faqat $stock ta bor"));
      return;
    }

    items[index] = items[index].copyWith(quantity: event.quantity);
    emit(state.copyWith(cartItems: items, clearError: true));
  }

  void _onRemove(RemoveFromCartEvent event, Emitter<SaleState> emit) {
    final items = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: items, clearError: true));
  }

  Future<void> _onComplete(
    CompleteSaleEvent event,
    Emitter<SaleState> emit,
  ) async {
    if (state.isCartEmpty) {
      emit(state.copyWith(error: "Savat bo'sh"));
      return;
    }
    if (event.amountPaid < state.totalAmount) {
      emit(state.copyWith(error: "To'langan summa yetarli emas"));
      return;
    }

    emit(
      state.copyWith(
        isProcessing: true,
        clearError: true,
        clearCompletedSale: true,
      ),
    );

    final sale = SaleModel(
      id: '',
      items: state.cartItems,
      subTotal: state.subTotal,
      tax: state.tax,
      total: state.totalAmount,
      paid: event.amountPaid,
      change: event.amountPaid - state.totalAmount,
      paymentMethod: state.paymentMethod,
      customerId: state.customer?.id,
      customerName: state.customer?.name,
      note: event.note ?? '',
      createdAt: event.date ?? DateTime.now(),
    );

    try {
      final id = await _saleRepository.createSale(sale);
      emit(
        state.copyWith(
          isProcessing: false,
          cartItems: const [],
          clearCustomer: true,
          completedSale: SaleModel(
            id: id,
            items: sale.items,
            subTotal: sale.subTotal,
            tax: sale.tax,
            total: sale.total,
            paid: sale.paid,
            change: sale.change,
            paymentMethod: sale.paymentMethod,
            customerId: sale.customerId,
            customerName: sale.customerName,
            note: sale.note,
            createdAt: sale.createdAt,
          ),
          actionMessage: "Savdo muvaffaqiyatli yakunlandi",
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isProcessing: false,
          error: Failure.from(error).message,
        ),
      );
    }
  }

  Future<void> _onRefund(
    RefundSaleEvent event,
    Emitter<SaleState> emit,
  ) async {
    emit(state.copyWith(isRefunding: true, clearError: true));
    try {
      await _saleRepository.refundSale(event.saleId);
      emit(
        state.copyWith(
          isRefunding: false,
          refundedSaleId: event.saleId,
          actionMessage: "Savdo qaytarildi",
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isRefunding: false,
          error: Failure.from(error).message,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

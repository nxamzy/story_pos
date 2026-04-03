import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProductBloc() : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final snapshot = await _firestore
              .collection('products')
              .where('userId', isEqualTo: user.uid)
              .get();

          final products = snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList();
          emit(ProductLoaded(products));
        }
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<AddProduct>((event, emit) async {
      try {
        final docRef = _firestore.collection('products').doc();

        final productWithId = ProductModel(
          id: docRef.id,
          name: event.product.name,
          userId: event.product.userId,
          barcode: event.product.barcode,
          buyPrice: event.product.buyPrice,
          sellPrice: event.product.sellPrice,
          stock: event.product.stock,
          category: event.product.category,
        );

        await docRef.set(productWithId.toMap());

        add(LoadProducts());
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });
  }
}

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
          // 🎯 BAZADAN FAQAT SHU USERID BO'LGANLARINI OLAMIZ
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

    // 2. Yangi mahsulot qo'shish
    on<AddProduct>((event, emit) async {
      try {
        // 1. Firebase'ga yangi doc yaratish
        final docRef = _firestore.collection('products').doc();

        // 2. Modelni Map-ga o'girib, yangi ID bilan saqlash
        final productWithId = ProductModel(
          id: docRef.id, // Firebase bergan ID ni yozamiz
          name: event.product.name,
          userId: event.product.userId,
          barcode: event.product.barcode,
          buyPrice: event.product.buyPrice,
          sellPrice: event.product.sellPrice,
          stock: event.product.stock,
          category: event.product.category,
        );

        await docRef.set(productWithId.toMap());

        // 3. Ro'yxatni qayta yuklash (State yangilanishi uchun)
        add(LoadProducts());
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });
  }
}

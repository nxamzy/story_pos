import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocam_pos/data/models/customer_model.dart';

// --- EVENTS ---
abstract class CustomerEvent {}

class LoadCustomersEvent extends CustomerEvent {}

class AddManualCustomerEvent extends CustomerEvent {
  final CustomerModel customer;
  AddManualCustomerEvent(this.customer);
}

class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;
  DeleteCustomerEvent(this.customerId);
}

class SearchCustomerEvent extends CustomerEvent {
  final String query;
  SearchCustomerEvent(this.query);
}

// 🔥 Ichki event: Stream'dan kelgan ma'lumotni State'ga urish uchun
class _UpdateCustomersEvent extends CustomerEvent {
  final List<CustomerModel> customers;
  _UpdateCustomersEvent(this.customers);
}

// --- STATE ---
class CustomerState {
  final List<CustomerModel> customers;
  final List<CustomerModel> searchResults;
  final bool isLoading;
  final String? error;

  CustomerState({
    this.customers = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  CustomerState copyWith({
    List<CustomerModel>? customers,
    List<CustomerModel>? searchResults,
    bool? isLoading,
    String? error,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// --- BLOC ---
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _customerSubscription;

  CustomerBloc() : super(CustomerState()) {
    // 1. REAL-TIME YUKLASH (Stream ulaymiz)
    on<LoadCustomersEvent>((event, emit) {
      emit(state.copyWith(isLoading: true));
      final userId = FirebaseAuth.instance.currentUser?.uid ?? "";

      if (userId.isEmpty) {
        emit(state.copyWith(isLoading: false, error: "User not logged in"));
        return;
      }

      // Eski obunani tozalaymiz
      _customerSubscription?.cancel();

      // 🔥 Firebase Stream boshlandi
      _customerSubscription = _firestore
          .collection('users')
          .doc(userId)
          .collection('customers')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              final list = snapshot.docs
                  .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
                  .toList();
              // Ma'lumot kelsa, ichki eventni chaqiramiz
              add(_UpdateCustomersEvent(list));
            },
            onError: (e) {
              print("Firestore Error: $e");
            },
          );
    });

    // 2. STATE'NI YANGILASH (Stream'dan kelgan ma'lumot bilan)
    on<_UpdateCustomersEvent>((event, emit) {
      emit(
        state.copyWith(
          customers: event.customers,
          searchResults:
              event.customers, // Qidiruv bo'lmasa hammasini ko'rsatadi
          isLoading: false,
        ),
      );
    });

    // 3. YANGI MIJOZ QO'SHISH
    on<AddManualCustomerEvent>((event, emit) async {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('customers')
            .doc(event.customer.id)
            .set(event.customer.toMap(), SetOptions(merge: true));
      } catch (e) {
        emit(state.copyWith(error: "Saqlashda xatolik: $e"));
      }
    });

    // 4. MIJOZNI O'CHIRISH
    on<DeleteCustomerEvent>((event, emit) async {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      try {
        // Bazadan o'chirish
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('customers')
            .doc(event.customerId)
            .delete();

        // 🔥 MUHIM: O'chgandan keyin stateni ham tozalash:
        final updatedList = state.customers
            .where((c) => c.id != event.customerId)
            .toList();
        emit(
          state.copyWith(
            customers: updatedList,
            searchResults: updatedList, // Qidiruv ro'yxatidan ham o'chsin
          ),
        );
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
    // 5. QIDIRUV
    on<SearchCustomerEvent>((event, emit) {
      if (event.query.isEmpty) {
        emit(state.copyWith(searchResults: state.customers));
      } else {
        final filtered = state.customers.where((c) {
          final nameMatch = c.name.toLowerCase().contains(
            event.query.toLowerCase(),
          );
          final phoneMatch = c.phone.contains(event.query);
          return nameMatch || phoneMatch;
        }).toList();
        emit(state.copyWith(searchResults: filtered));
      }
    });
  }

  @override
  Future<void> close() {
    _customerSubscription?.cancel(); // Bloc yopilganda streamni o'chiramiz
    return super.close();
  }
}

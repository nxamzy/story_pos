import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocam_pos/data/models/user_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileBloc() : super(ProfileInitial()) {
    // --- PROFILNI YUKLASH ---
    on<LoadUserProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        // Firestore'dan foydalanuvchi hujjatini olamiz
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(event.uid)
            .get();

        if (doc.exists) {
          // Ma'lumotni Modelga o'giramiz
          UserModel user = UserModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
          emit(ProfileLoaded(user));
        } else {
          emit(const ProfileError("Foydalanuvchi ma'lumotlari topilmadi!"));
        }
      } catch (e) {
        emit(ProfileError("Xatolik yuz berdi: ${e.toString()}"));
      }
    });

    // --- PROFILNI YANGILASH ---
    on<UpdateUserProfile>((event, emit) async {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'firstName': event.firstName,
          'lastName': event.lastName,
        });
        // Yangilangandan keyin qayta yuklash buyrug'ini beramiz
        add(LoadUserProfile(currentUser.uid));
      } catch (e) {
        emit(ProfileError("Yangilashda xatolik: ${e.toString()}"));
      }
    });
  }
}

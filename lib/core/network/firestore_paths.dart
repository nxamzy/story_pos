import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocam_pos/core/network/exceptions.dart';

/// Firestore'dagi barcha yo'llar shu yerda — boshqa hech qayerda
/// `collection('...')` yozilmaydi.
///
/// Muhim: har bir do'kon (foydalanuvchi) ma'lumoti `users/{uid}/...`
/// ostida saqlanadi. Shu sababli bir foydalanuvchi boshqasining
/// mahsulotini, mijozini yoki kassasini ko'ra olmaydi.
class FirestorePaths {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirestorePaths({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Joriy foydalanuvchi uid'si. Kirmagan bo'lsa exception tashlaydi.
  String get uid {
    final id = _auth.currentUser?.uid;
    if (id == null || id.isEmpty) throw const UnauthenticatedException();
    return id;
  }

  bool get isSignedIn => _auth.currentUser != null;

  DocumentReference<Map<String, dynamic>> get userDoc =>
      _db.collection(users).doc(uid);

  CollectionReference<Map<String, dynamic>> get products =>
      userDoc.collection('products');

  CollectionReference<Map<String, dynamic>> get customers =>
      userDoc.collection('customers');

  CollectionReference<Map<String, dynamic>> get suppliers =>
      userDoc.collection('suppliers');

  CollectionReference<Map<String, dynamic>> get sales =>
      userDoc.collection('sales');

  CollectionReference<Map<String, dynamic>> get employees =>
      userDoc.collection('employees');

  CollectionReference<Map<String, dynamic>> get transferLogs =>
      userDoc.collection('transfer_logs');

  CollectionReference<Map<String, dynamic>> get expenses =>
      userDoc.collection('expenses');

  /// Kassa (drawer) hujjati — do'kon bo'yicha bitta.
  DocumentReference<Map<String, dynamic>> get drawer =>
      userDoc.collection('pos_settings').doc('drawer_info');

  FirebaseFirestore get db => _db;

  static const String users = 'users';
}

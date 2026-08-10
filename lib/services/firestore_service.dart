import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USERS ───────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ─── PRODUCTS ─────────────────────────────────────────
  Future<void> addFavorite(String userId, String productId) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({
      'favorites': FieldValue.arrayUnion([productId]),
    });
  }

  Future<void> removeFavorite(String userId, String productId) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({
      'favorites': FieldValue.arrayRemove([productId]),
    });
  }

  Future<List<ProductModel>> getFavoriteProducts(
      List<String> favoriteIds) async {
    if (favoriteIds.isEmpty) return [];
    final snapshot = await _db
        .collection('products')
        .where(FieldPath.documentId, whereIn: favoriteIds)
        .get();
    return snapshot.docs
        .map((doc) =>
            ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<List<ProductModel>> getProducts({String? category}) {
    Query query =
        _db.collection('products').orderBy('createdAt', descending: true);
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((doc) =>
            ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addProduct(ProductModel product) async {
    await _db.collection('products').add({
      ...product.toMap(),
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateProductReviews(String productId, double newRating,
      int newCount, List<Map<String, dynamic>> reviews) async {
    await _db.collection('products').doc(productId).update({
      'rating': newRating,
      'reviewCount': newCount,
      'reviews': reviews
          .map((r) => {
                'userName': r['userName'],
                'rating': r['rating'],
                'text': r['text'],
                'timestamp': r['timestamp'],
              })
          .toList(),
    });
  }

  Stream<List<ProductModel>> getArtisanProducts(String artisanId) {
    return _db
        .collection('products')
        .where('artisanId', isEqualTo: artisanId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ProductModel.fromMap(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}

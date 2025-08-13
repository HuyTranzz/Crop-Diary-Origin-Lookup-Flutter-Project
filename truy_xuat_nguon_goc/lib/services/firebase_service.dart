import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  // Tìm sản phẩm theo trường 'id'
  Future<DocumentSnapshot?> getProductByCustomId(String productId) async {
    QuerySnapshot querySnapshot = await _productsCollection
        .where('id', isEqualTo: productId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    return null;
  }

  // Lấy stream sản phẩm theo trường 'id' (dùng cho cập nhật realtime nếu cần)
  Stream<DocumentSnapshot?> getProductStreamByCustomId(String productId) {
    return _productsCollection
        .where('id', isEqualTo: productId)
        .limit(1)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null);
  }
}
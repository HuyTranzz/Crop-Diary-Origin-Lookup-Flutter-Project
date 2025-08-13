import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product.dart';
import 'imgur_service.dart';

class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _productsCollection =
  FirebaseFirestore.instance.collection('products');

  // Get products stream
  Stream<QuerySnapshot> getProductsStream() {
    return _productsCollection.snapshots();
  }

  // Get product by ID
  Future<DocumentSnapshot> getProductById(String productId) {
    return _productsCollection.doc(productId).get();
  }

  // Add new product with ID handling
  Future<String> addProduct(Product product, File? imageFile) async {
    String? imageUrl = await _uploadImage(imageFile);

    // Create product data map
    Map<String, dynamic> productData = product.toMap();
    if (imageUrl != null) {
      productData['image'] = imageUrl;
    }

    // If product has an ID, use it; otherwise, let Firestore generate one
    if (product.id.isNotEmpty) {
      await _productsCollection.doc(product.id).set(productData);
      return product.id; // Return the custom ID
    } else {
      DocumentReference docRef = await _productsCollection.add(productData);
      return docRef.id; // Return the generated ID
    }
  }

  // Update product
  Future<void> updateProduct(
      String productId, Product product, File? imageFile, String? existingImageUrl) async {
    String? imageUrl = existingImageUrl;

    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile);
    }

    // Create updated product data map
    Map<String, dynamic> productData = product.toMap();
    if (imageUrl != null) {
      productData['image'] = imageUrl;
    }

    // Ensure we're updating the correct document
    return _productsCollection.doc(productId).update(productData);
  }

  // Upload image with Imgur as primary and Firebase as fallback
  Future<String?> _uploadImage(File? imageFile) async {
    if (imageFile == null) return null;

    try {
      // First try uploading to Imgur
      String? imgurUrl = await ImgurService.uploadImage(imageFile);
      if (imgurUrl != null) {
        return imgurUrl;
      }

      // If Imgur fails, use Firebase Storage as fallback
      String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}';
      Reference storageRef = _storage.ref().child('products/$fileName');

      await storageRef.putFile(imageFile);
      String downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null; // Consider throwing an exception if this is critical
    }
  }

  // Update product care
  Future<void> updateProductCare(
      String productId, String careType, Map<String, dynamic> careData) async {
    return await _productsCollection.doc(productId).update({
      'care.$careType': FieldValue.arrayUnion([careData])
    });
  }

  // Delete product
  Future<void> deleteProduct(String productId) {
    return _productsCollection.doc(productId).delete();
  }

  // Get product stream by ID
  Stream<DocumentSnapshot> getProductStream(String productId) {
    return _productsCollection.doc(productId).snapshots();
  }
}
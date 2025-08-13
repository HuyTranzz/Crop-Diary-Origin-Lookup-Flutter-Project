import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String productId;
  final String variety;
  final String storageLocation;
  final String productionFacility;
  final String harvestDate;
  final String lastUpdated;
  final String imageUrl;
  final Map<String, dynamic> care;

  Product({
    required this.id,
    required this.name,
    required this.productId,
    this.variety = '',
    this.storageLocation = '',
    this.productionFacility = '',
    this.harvestDate = '',
    this.lastUpdated = '',
    this.imageUrl = '',
    Map<String, dynamic>? care,
  }) : this.care = care ?? {
          'fertilization': [],
          'watering': [],
          'spraying': [],
        };

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      productId: data['id'] ?? '',
      variety: data['variety'] ?? '',
      storageLocation: data['storageLocation'] ?? '',
      productionFacility: data['productionFacility'] ?? '',
      harvestDate: data['harvestDate'] ?? '',
      lastUpdated: data['lastUpdated'] ?? '',
      imageUrl: data['image'] ?? '',
      care: data['care'] ?? {
        'fertilization': [],
        'watering': [],
        'spraying': [],
      },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': productId,
      'variety': variety,
      'storageLocation': storageLocation,
      'productionFacility': productionFacility,
      'harvestDate': harvestDate,
      'lastUpdated': lastUpdated,
      'image': imageUrl,
      'care': care,
    };
  }
}
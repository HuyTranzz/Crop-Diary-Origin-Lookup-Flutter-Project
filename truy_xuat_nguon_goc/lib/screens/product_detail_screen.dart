import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '/services/firebase_service.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  final FirebaseService _firebaseService = FirebaseService();

  ProductDetailScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false, // Đảm bảo nội dung không tràn lên AppBar
      appBar: AppBar(
        title: const Text(
          'Chi Tiết Sản Phẩm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.deepPurple[700],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[50]!, Colors.white],
          ),
        ),
        child: FutureBuilder<DocumentSnapshot?>(
          future: _firebaseService.getProductByCustomId(productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Không tìm thấy sản phẩm',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            Product product = Product.fromFirestore(snapshot.data!);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.imageUrl.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showFullImage(context, product.imageUrl),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget:
                                (context, url, error) => const Icon(
                              Icons.error,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          title: 'Đặc Điểm',
                          children: [
                            _buildInfoRow('Tên', product.name),
                            _buildInfoRow('Mã sản phẩm', product.productId),
                            _buildInfoRow('Giống', product.variety),
                            _buildInfoRow(
                              'Nơi lưu trữ',
                              product.storageLocation,
                            ),
                            _buildInfoRow(
                              'Ngày thu hoạch',
                              _formatDate(product.harvestDate),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          title: 'Cơ Sở Sản Xuất',
                          children: [
                            Text(
                              product.productionFacility.isEmpty
                                  ? 'Không xác định'
                                  : product.productionFacility,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCareSection(context, product.care),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return date.isEmpty ? 'Không xác định' : date;
    }
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Divider(color: Colors.deepPurple, height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCareSection(BuildContext context, Map<String, dynamic> care) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông Tin Canh Tác',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Divider(color: Colors.deepPurple, height: 20),
            _buildExpandableTile(
              context: context,
              title: 'Tưới Nước',
              count: care['watering']?.length ?? 0,
              items: care['watering'] ?? [],
            ),
            const SizedBox(height: 8),
            _buildExpandableTile(
              context: context,
              title: 'Bón Phân',
              count: care['fertilization']?.length ?? 0,
              items: care['fertilization'] ?? [],
            ),
            const SizedBox(height: 8),
            _buildExpandableTile(
              context: context,
              title: 'Phun Thuốc',
              count: care['spraying']?.length ?? 0,
              items: care['spraying'] ?? [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Không xác định' : value,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableTile({
    required BuildContext context,
    required String title,
    required int count,
    required List<dynamic> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Số lần: $count',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        collapsedBackgroundColor: Colors.deepPurple[50],
        backgroundColor: Colors.white,
        childrenPadding: const EdgeInsets.all(16),
        children:
        items.isEmpty
            ? [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Không có dữ liệu',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ]
            : items
            .map<Widget>((item) => _buildCareItem(context, item))
            .toList(),
      ),
    );
  }

  Widget _buildCareItem(BuildContext context, dynamic item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Ngày', _formatDate(item['date'])),
            _buildInfoRow('Ghi chú', item['note'] ?? 'Không có'),
            if (item['evidence'] != null && item['evidence'].isNotEmpty)
              GestureDetector(
                onTap: () => _showFullImage(context, item['evidence']),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: item['evidence'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
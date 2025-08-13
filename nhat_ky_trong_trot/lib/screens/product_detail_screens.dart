import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import 'edit_product_screens.dart';
import 'update_care_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  final FirebaseService _firebaseService = FirebaseService();

  ProductDetailScreen({required this.productId});
// Lấy dữ liệu sản phẩm từ Firestore
  String formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Không xác định';
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi Tiết Nông Sản',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.deepPurple[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProductScreen(productId: productId),
                ),
              );
            },
            tooltip: 'Chỉnh sửa',
          ),
        ],
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firebaseService.getProductStream(productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Đã xảy ra lỗi: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'Không tìm thấy sản phẩm',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            Product product = Product.fromFirestore(snapshot.data!);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                                (context, url, error) =>
                            const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildInfoCard('Thông Tin Cơ Bản', [
                    _buildInfoRow('Tên cây', product.name),
                    _buildInfoRow('ID', product.productId),
                    _buildInfoRow('Loại giống', product.variety),
                    _buildInfoRow('Vị trí ', product.storageLocation),
                    _buildInfoRow('Cơ sở sản xuất', product.productionFacility),
                    _buildInfoRow('Ngày thu hoạch', product.harvestDate),
                    _buildInfoRow(
                      'Ngày cập nhật',
                      formatDateTime(product.lastUpdated),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildCareSection(context, product.care),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateCareScreen(productId: productId),
              ),
            );
          },
          label: const Text(
            'Cập Nhật Chăm Sóc',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.local_florist, size: 24),
          backgroundColor: Colors.deepPurple[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          extendedPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCareSection(BuildContext context, Map<String, dynamic> care) {
    List<Widget> cards = [];

    void addCareCard(String title, List<dynamic> items) {
      if (items.isNotEmpty) {
        cards.add(
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ExpansionTile(
              title: Text(
                '$title (${items.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              collapsedBackgroundColor: Colors.deepPurple[50],
              backgroundColor: Colors.white,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    items.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lần ${entry.key + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCareItem(context, entry.value),
                            if (entry.key < items.length - 1)
                              const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (care.containsKey('watering') && care['watering'] is List)
      addCareCard('Lịch Sử Tưới Nước', care['watering']);
    if (care.containsKey('fertilization') && care['fertilization'] is List)
      addCareCard('Lịch Sử Bón Phân', care['fertilization']);
    if (care.containsKey('spraying') && care['spraying'] is List)
      addCareCard('Lịch Sử Phun Thuốc', care['spraying']);

    return cards.isEmpty
        ? Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Chưa có lịch sử chăm sóc',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    )
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: cards);
  }

  Widget _buildCareItem(BuildContext context, dynamic entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Ngày', formatDateTime(entry['date'])),
        if (entry.containsKey('type'))
          _buildInfoRow('Loại', entry['type'] ?? 'N/A'),
        _buildInfoRow('Ghi chú', entry['note'] ?? 'Không có'),
        if (entry['evidence'] != null && entry['evidence'].isNotEmpty)
          GestureDetector(
            onTap: () => _showFullImage(context, entry['evidence']),
            child: Card(
              margin: const EdgeInsets.only(top: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: entry['evidence'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                  const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> rows) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                color: Colors.black87,
              ),
            ),
            const Divider(color: Colors.deepPurple),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? 'Không xác định' : value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
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

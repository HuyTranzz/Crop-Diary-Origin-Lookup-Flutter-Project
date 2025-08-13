import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import '../services/imgur_service.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  EditProductScreen({required this.productId});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _storageController = TextEditingController();
  final _productionFacility = TextEditingController();
  final _harvestDateController = TextEditingController();
  final _productIdController = TextEditingController();
  String? _imageUrl;
  File? _newImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }
//Lấy dữ liệu từ Firebase
  Future<void> _loadProductData() async {
    var productSnapshot = await _firebaseService.getProductById(
      widget.productId,
    );
    if (productSnapshot.exists) {
      Product product = Product.fromFirestore(productSnapshot);
      setState(() {
        _nameController.text = product.name;
        _varietyController.text = product.variety;
        _storageController.text = product.storageLocation;
        _productionFacility.text = product.productionFacility;
        _harvestDateController.text = product.harvestDate;
        _productIdController.text = product.productId;
        _imageUrl = product.imageUrl;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _newImage = File(pickedFile.path));
    }
  }

  Future<void> _pickHarvestDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder:
          (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.green),
          buttonTheme: const ButtonThemeData(
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) {
      setState(
            () =>
        _harvestDateController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(pickedDate),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? uploadedImageUrl = _imageUrl;
      if (_newImage != null) {
        String? newUrl = await ImgurService.uploadImage(_newImage!);
        if (newUrl != null) uploadedImageUrl = newUrl;
      }

      Product updatedProduct = Product(
        id: widget.productId,
        name: _nameController.text,
        productId: _productIdController.text,
        variety: _varietyController.text,
        storageLocation: _storageController.text,
        productionFacility: _productionFacility.text,
        harvestDate: _harvestDateController.text,
        lastUpdated: DateTime.now().toIso8601String(),
        imageUrl: uploadedImageUrl ?? '',
        care:
        (await _firebaseService.getProductById(widget.productId)).data() !=
            null
            ? Product.fromFirestore(
          await _firebaseService.getProductById(widget.productId),
        ).care
            : null,
      );

      await _firebaseService.updateProduct(
        widget.productId,
        updatedProduct,
        null,
        uploadedImageUrl,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã cập nhật nông sản thành công'),
          backgroundColor: Colors.green[700],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật nông sản: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _storageController.dispose();
    _productionFacility.dispose();
    _harvestDateController.dispose();
    _productIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh Sửa Nông Sản',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.green[700],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child:
        _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hình ảnh nông sản',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickImage,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                            _newImage != null
                                ? Image.file(
                              _newImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                                : (_imageUrl != null &&
                                _imageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: _imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder:
                                  (
                                  context,
                                  url,
                                  ) => const Center(
                                child:
                                CircularProgressIndicator(),
                              ),
                              errorWidget:
                                  (context, url, error) =>
                              const Icon(
                                Icons.error,
                              ),
                            )
                                : Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Text(
                                  'Chưa có ảnh',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Chọn ảnh mới'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(
                              double.infinity,
                              50,
                            ),
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _nameController,
                  'Tên Nông Sản',
                  Icons.eco,
                  validator:
                      (value) =>
                  value!.isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _productIdController,
                  'Mã Sản Phẩm',
                  Icons.code,
                  validator:
                      (value) =>
                  value!.isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _varietyController,
                  'Giống',
                  Icons.category,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _storageController,
                  'Vị trí lưu trữ',
                  Icons.location_on,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _productionFacility,
                  'Cơ sở sản xuất',
                  Icons.factory_outlined,
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    controller: _harvestDateController,
                    readOnly: true,
                    onTap: _pickHarvestDate,
                    decoration: InputDecoration(
                      labelText: 'Ngày thu hoạch',
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.green,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Lưu Thay Đổi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        String? Function(String?)? validator,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

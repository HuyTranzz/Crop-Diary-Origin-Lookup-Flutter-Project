import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import '../widgets/image_picker_widget.dart';
import 'scanner_screen.dart';
//Đây là màn hình thêm nông sản (AddProductScreen) trong ứng dụng Flutter.
//Khai báo màn hình
class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}
//Các biến trạng thái
class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _varietyController = TextEditingController();
  final _storageLocationController = TextEditingController();
  final _productionFacility = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  DateTime? _harvestDate;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _varietyController.dispose();
    _storageLocationController.dispose();
    _productionFacility.dispose();
    super.dispose();
  }
//Cập nhật ảnh sản phẩm
  void _updateImage(File file) {
    setState(() => _imageFile = file);
  }

  //Xử lý lưu nông sản lên Firestore
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Product product = Product(
        id: '',
        name: _nameController.text,
        productId: _idController.text,
        variety: _varietyController.text,
        storageLocation: _storageLocationController.text,
        productionFacility: _productionFacility.text,
        lastUpdated: DateTime.now().toIso8601String(),
        harvestDate:
        _harvestDate != null
            ? DateFormat('yyyy-MM-dd').format(_harvestDate!)
            : '',
      );

      await _firebaseService.addProduct(product, _imageFile);
// Thông báo khi lưu thành công hoặc lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nông sản đã được lưu thành công'),
          backgroundColor: Colors.deepPurple[700],
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu nông sản: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
//Quét mã QR để nhập ID sản phẩm
  void _scanCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanScreen()),
    );

    if (result != null && result is String) {
      setState(() => _idController.text = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm Nông Sản Mới',
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
        child:
        _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
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
                    child: ImagePickerWidget(
                      imageFile: _imageFile,
                      onImagePicked: _updateImage,
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
                  value!.isEmpty ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _idController,
                        'ID Nông Sản',
                        Icons.tag,
                        validator:
                            (value) =>
                        value!.isEmpty
                            ? 'Vui lòng nhập ID'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.deepPurple,
                        size: 28,
                      ),
                      onPressed: _scanCode,
                      tooltip: 'Quét mã',
                      padding: const EdgeInsets.all(8),
                      color: Colors.deepPurple[700],
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.deepPurple[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _varietyController,
                  'Giống',
                  Icons.category,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _storageLocationController,
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
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.lightBlue,
                    ),
                    title: const Text(
                      'Ngày thu hoạch',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _harvestDate != null
                          ? DateFormat(
                        'dd/MM/yyyy',
                      ).format(_harvestDate!)
                          : 'Chưa chọn',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder:
                            (context, child) => Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.deepPurple,
                            ),
                            buttonTheme: const ButtonThemeData(
                              textTheme: ButtonTextTheme.primary,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (pickedDate != null)
                        setState(() => _harvestDate = pickedDate);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.deepPurple[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Lưu Nông Sản',
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
          prefixIcon: Icon(icon, color: Colors.deepPurple),
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

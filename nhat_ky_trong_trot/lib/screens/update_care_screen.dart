import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firebase_service.dart';
import '../services/imgur_service.dart';

class UpdateCareScreen extends StatefulWidget {
  final String productId;
  const UpdateCareScreen({required this.productId});

  @override
  _UpdateCareScreenState createState() => _UpdateCareScreenState();
}

class _UpdateCareScreenState extends State<UpdateCareScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  File? _evidenceImage;
  String _careType = 'watering';
  final _typeController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() => _evidenceImage = File(pickedFile.path));
    }
  }

  Future<void> _submitCareUpdate() async {
    if (!_formKey.currentState!.validate() || _evidenceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chụp ảnh minh chứng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = await ImgurService.uploadImage(_evidenceImage!);
      if (imageUrl != null) {
        Map<String, dynamic> careData = {
          'date': DateTime.now().toIso8601String(),
          'evidence': imageUrl,
          'note': _noteController.text,
        };

        if (_careType == 'fertilization' || _careType == 'spraying') {
          careData['type'] = _typeController.text;
        }

        await _firebaseService.updateProductCare(
          widget.productId,
          _careType,
          careData,
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã cập nhật thông tin chăm sóc'),
            backgroundColor: Colors.deepPurple[700],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red[700]),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cập Nhật Chăm Sóc',
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
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _careType,
                          decoration: InputDecoration(
                            labelText: 'Loại chăm sóc',
                            prefixIcon: Icon(
                              Icons.local_florist,
                              color: Colors.deepPurple,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'watering',
                              child: Text('Tưới nước'),
                            ),
                            DropdownMenuItem(
                              value: 'fertilization',
                              child: Text('Bón phân'),
                            ),
                            DropdownMenuItem(
                              value: 'spraying',
                              child: Text('Phun thuốc'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _careType = value!;
                              _typeController.clear();
                            });
                          },
                        ),
                        if (_careType != 'watering')
                          const SizedBox(height: 16),
                        if (_careType != 'watering')
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextFormField(
                              controller: _typeController,
                              decoration: InputDecoration(
                                labelText:
                                _careType == 'fertilization'
                                    ? 'Loại phân bón'
                                    : 'Loại thuốc',
                                prefixIcon: Icon(
                                  Icons.category,
                                  color: Colors.deepPurple,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                              ),
                              validator:
                                  (value) =>
                              value!.isEmpty
                                  ? 'Vui lòng nhập loại'
                                  : null,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextFormField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              labelText: 'Ghi chú',
                              prefixIcon: Icon(
                                Icons.note,
                                color: Colors.deepPurple,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                              const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                          'Ảnh minh chứng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                          _evidenceImage != null
                              ? Image.file(
                            _evidenceImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
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
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Chụp ảnh minh chứng'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(
                              double.infinity,
                              50,
                            ),
                            backgroundColor: Colors.deepPurple[700],
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitCareUpdate,
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
                    'Lưu Thông Tin Chăm Sóc',
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
}

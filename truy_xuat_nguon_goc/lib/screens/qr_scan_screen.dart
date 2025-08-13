import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_detail_screen.dart';

class QRScanScreen extends StatefulWidget {
  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _saveToHistory(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('scan_history') ?? [];
    final timestamp = DateTime.now().toIso8601String();
    final newEntry = '$productId|$timestamp';
    history.insert(0, newEntry); // Lưu mỗi lần, không kiểm tra trùng
    await prefs.setStringList('scan_history', history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture capture) async {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? productId = barcode.rawValue;
            if (productId != null) {
              await controller.stop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(productId: productId),
                ),
              );
              await _saveToHistory(productId); // Lưu khi quay lại từ ProductDetailScreen
              Navigator.pop(context, productId); // Trả về productId cho HomeScreen
              break;
            }
          }
        },
      ),
    );
  }
}
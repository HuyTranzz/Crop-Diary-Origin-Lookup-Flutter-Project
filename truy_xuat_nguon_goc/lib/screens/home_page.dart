import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'qr_scan_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('scan_history') ?? [];

    setState(() {
      history = historyList.map((entry) {
        final parts = entry.split('|');
        return {
          'productId': parts[0],
          'timestamp': parts.length > 1 ? parts[1] : DateTime.now().toIso8601String(),
        };
      }).toList();
      history.sort((a, b) => DateTime.parse(b['timestamp']!).compareTo(DateTime.parse(a['timestamp']!)));
    });
  }

  Future<void> _saveScanHistory(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHistory = prefs.getStringList('scan_history') ?? [];
    final timestamp = DateTime.now().toIso8601String();
    final newEntry = '$productId|$timestamp';
    currentHistory.insert(0, newEntry);
    await prefs.setStringList('scan_history', currentHistory);
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Truy Xuất Nguồn Gốc',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 4,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 24, color: Colors.white),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Thông tin',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildButton(context, 'Quét QR', Icons.qr_code_scanner, () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScanScreen()),
              );
              if (result != null && result is String) {
                await _loadHistory();
              }
            }),
            const SizedBox(height: 20),
            Expanded(child: _buildHistoryConsole()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: Icon(icon, size: 28),
      label: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHistoryConsole() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Text(
                'Lịch Sử Truy Xuất',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? const Center(
              child: Text('Chưa có lịch sử truy xuất', style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
                : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  leading: const Icon(Icons.qr_code, color: Colors.deepPurple),
                  title: Text('Mã: ${item['productId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Thời gian: ${_formatTimestamp(item['timestamp']!)}', style: TextStyle(color: Colors.grey[600])),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.deepPurple),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: item['productId']!)),
                    );
                    await _saveScanHistory(item['productId']!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Thông tin ứng dụng', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Ứng dụng Truy Xuất Nguồn Gốc - Phiên bản 1.0.0\nNhà phát triển: Trần Gia Huy-Nguyễn Việt Anh'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

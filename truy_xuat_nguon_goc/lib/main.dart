import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo binding được khởi tạo
  // Khởi tạo Firebase với cấu hình từ DefaultFirebaseOptions
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhật ký trồng trọt',
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: SplashScreen(), // Thay HomeScreen() bằng SplashScreen()
      debugShowCheckedModeBanner: false,
    );
  }
}
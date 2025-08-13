import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhật Ký Trồng Trọt',
      theme: appTheme, // Từ file theme.dart
      home: SplashScreen(), // Thay ProductListScreen() bằng SplashScreen()
      debugShowCheckedModeBanner: false,
    );
  }
}

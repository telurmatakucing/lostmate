import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:lostmate/presentation/screens/auth/login_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Kalau mau matikan, ganti ke false
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lostmatebaru',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true, // Ini penting untuk device_preview
      locale: DevicePreview.locale(context), // Ini juga dari device_preview
      builder: DevicePreview.appBuilder, // Ini untuk membungkus tampilan
      theme: ThemeData(
        primaryColor: const Color(0xFFFFC554),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC554),
          primary: const Color(0xFFFFC554),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

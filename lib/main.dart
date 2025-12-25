// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coba_1/features/auth/splash_screen.dart';
import 'package:coba_1/core/theme_provider.dart';
import 'package:coba_1/core/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Gawee App',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode, 
          
          // --- PERUBAHAN DI SINI ---
          theme: AppTheme.lightTheme(
            themeProvider.primaryColor, // Warna ungu konstan
            themeProvider.lightScaffoldColor, // Warna latar dinamis
          ),
          darkTheme: AppTheme.darkTheme(
            themeProvider.primaryColor, // Warna ungu konstan
          ), 
          
          home: const SplashScreen(),
        );
      },
    );
  }
}
import 'package:applications/home_page.dart';
import 'package:flutter/material.dart';
import 'package:applications/palette.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'assistant',
      theme: ThemeData.light(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: Palette.whiteColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: Palette.whiteColor,
          )),
      home: const HomePage(),
    );
  }
}

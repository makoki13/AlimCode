import 'package:flutter/material.dart';
import 'screens/init_screen.dart'; // Importamos la nueva pantalla

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlimCode',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const InitScreen(), // Cambiamos la pantalla inicial a InitScreen
    );
  }
}

import 'package:flutter/material.dart';

class InitScreen extends StatelessWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen de logo (asegúrate de tenerla en assets/images/logo.png)
            Image.asset(
              'assets/images/logo.png', // Ruta de la imagen
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            // Nombre de la aplicación
            const Text(
              'AlimCode',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            // Versión de la aplicación
            const Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
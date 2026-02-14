import 'package:flutter/material.dart';
import 'list_alimentos_screen.dart';
import 'new_product_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(50.0), // Margen del 25% (ajustable)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón central con imagen de código de barras (deshabilitado)
              Expanded(
                flex: 3,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      // Botón deshabilitado temporalmente
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Lectura de código de barras no disponible aún',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors
                            .grey[300], // Color gris para indicar deshabilitado
                      ),
                      child: Image.asset(
                        'assets/images/barcode_icon.png', // Asegúrate de tener esta imagen
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.width / 2,
                        fit: BoxFit.contain,
                        color: Colors.grey, // Hacer la imagen más tenue
                      ),
                    ),
                  ),
                ),
              ),
              // Menú inferior
              Expanded(
                flex: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ListAlimentosScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewProductScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

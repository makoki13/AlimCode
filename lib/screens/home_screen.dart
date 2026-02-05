import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'new_product_screen.dart';
import '../services/bar_items.dart';
import '../models/bar.dart'; // Asegúrate de importar Bar

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
              // Botón central con imagen de código de barras
              Expanded(
                flex: 3,
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      // Código de barras simulado
                      final codigo = "00000000000000";
                      final bar = Bar(codigo);

                      bool encontrado = await BarItems.existeBar(bar);

                      if (!encontrado) {
                        // Mostrar mensaje de error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("El código de barras leído no ha sido encontrado."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      // Aquí puedes agregar la lógica para el caso en que sí se encuentre
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        'assets/images/barcode_icon.png', // Asegúrate de tener esta imagen
                        width:
                            MediaQuery.of(context).size.width /
                            2, // Ocupa la mitad del ancho de la pantalla
                        height:
                            MediaQuery.of(context).size.width /
                            2, // Proporcional si es cuadrada
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              // Menú inferior
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
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
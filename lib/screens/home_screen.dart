// ignore_for_file: use_build_context_synchronously

import 'package:alimcode/screens/list_alimentos_screen.dart';
import 'package:alimcode/services/local_service.dart';
import 'package:flutter/material.dart';
import 'new_product_screen.dart';
import 'precio_compra_screen.dart'; // Importamos la nueva pantalla
import '../models/bar.dart'; // Asegúrate de importar Bar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Bar bar = Bar('0000000000001'); // Variable compartida

  @override
  void initState() {
    super.initState();
    bar = Bar('0000000000030'); // Inicializamos aquí
  }

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
                      final service = SQLiteLocalService();
                      final alimento = await service.obtenerProducto(bar);

                      if (alimento == null) {
                        // Directamente navegar a la pantalla de formulario
                        final precio = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewProductScreen(bar: bar),
                          ),
                        );

                        if (precio != null) {
                          print('Precio ingresado: €$precio');
                        }
                      } else {
                        // Directamente pedir el precio del producto encontrado
                        final precio = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PrecioCompraScreen(tipoProducto: alimento.tipo),
                          ),
                        );
                        // Mostrar precio en consola
                        if (precio != null) {
                          print('Precio ingresado: €$precio');
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        'assets/images/barcode_icon.png', // Asegúrate de tener esta imagen
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.width / 2,
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
                        onPressed: () async {
                          final precio = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewProductScreen(bar: bar),
                            ),
                          );

                          if (precio != null) {
                            print('Precio ingresado: €$precio');
                          }
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

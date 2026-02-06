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
    bar = Bar('0000000000000'); // Inicializamos aquí
  }

  @override
  Widget build(BuildContext context) {
    // Código de barras simulado
    //final codigo = "00000000000000";
    //bar = Bar(codigo); // Asignamos el valor aquí

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
                        // Mostrar popup de error
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Código no encontrado"),
                              content: const Text(
                                "El código de barras leído no ha sido encontrado.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Cerrar el popup
                                    // Navegar a la pantalla de formulario
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NewProductScreen(bar: bar),
                                      ),
                                    ).then((_) async {
                                      // Después de crear el producto, pedir el precio
                                      // ignore: unused_local_variable
                                      final precio = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PrecioCompraScreen(
                                            tipoProducto:
                                                'Producto sin nombre', // Puedes actualizarlo
                                          ),
                                        ),
                                      );
                                      // Aquí terminamos, sin mostrar diálogo adicional
                                    });
                                  },
                                  child: const Text("Aceptar"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Producto encontrado"),
                              content: Text(
                                "Tipo: ${alimento.tipo}\n"
                                "Preparación: ${alimento.preparacion}\n"
                                "Cantidad: ${alimento.cantidad}",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Cerrar el popup

                                    // Pedir el precio del producto encontrado
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PrecioCompraScreen(
                                              tipoProducto: alimento.tipo,
                                            ),
                                      ),
                                    ).then((precio) async {
                                      // Aquí terminamos, sin mostrar diálogo adicional
                                    });
                                  },
                                  child: const Text("Aceptar"),
                                ),
                              ],
                            );
                          },
                        );
                      }
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
                              builder: (context) => NewProductScreen(
                                bar: bar,
                              ), // ✅ Comparte la misma variable
                            ),
                          ).then((_) async {
                            // Después de crear el producto, pedir el precio
                            final precio = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrecioCompraScreen(
                                  tipoProducto:
                                      'Producto sin nombre', // Puedes actualizarlo
                                ),
                              ),
                            );
                            // Aquí terminamos, sin mostrar diálogo adicional
                          });
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

import 'package:alimcode/screens/list_alimentos_screen.dart';
import 'package:flutter/material.dart';
import 'new_product_screen.dart';
import '../services/bar_items.dart';
import '../models/bar.dart'; // Asegúrate de importar Bar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Bar bar = Bar('0000000000000'); // Variable compartida

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
                      bool encontrado = await BarItems.existeBar(bar);

                      if (!encontrado) {
                        // Mostrar popup de error
                        showDialog(
                          // ignore: use_build_context_synchronously
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
                                    );
                                  },
                                  child: const Text("Aceptar"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Aquí puedes agregar la lógica para el caso en que sí se encuentre
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

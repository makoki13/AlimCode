// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/alimento.dart';

class ListAlimentosScreen extends StatefulWidget {
  const ListAlimentosScreen({super.key});

  @override
  State<ListAlimentosScreen> createState() => _ListAlimentosScreenState();
}

class _ListAlimentosScreenState extends State<ListAlimentosScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Alimento>> _alimentosFuture;

  @override
  void initState() {
    super.initState();
    _cargarAlimentos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargarAlimentos() {
    setState(() {
      _alimentosFuture = DatabaseHelper().getAlimentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Lista de Alimentos'),
      ),
      body: Column(
        children: [
          // Área de búsqueda fija
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar alimento...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica de búsqueda se implementará después
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Lista con scroll independiente
          Expanded(
            child: FutureBuilder<List<Alimento>>(
              future: _alimentosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final alimentos = snapshot.data ?? [];
                  if (alimentos.isEmpty) {
                    return const Center(
                      child: Text('No hay alimentos guardados.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: alimentos.length,
                    itemBuilder: (context, index) {
                      final alimento = alimentos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Título del alimento
                              Text(
                                alimento.tipo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Subtítulo con preparación y cantidad (formato original)
                              Text(
                                '${alimento.preparacion}\n${alimento.cantidad}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Línea separadora sutil antes de los iconos
                              const Divider(height: 1, thickness: 0.5),
                              const SizedBox(height: 8),
                              // Iconos en su propia línea, alineados a la derecha
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.receipt_outlined,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      _mostrarHistorialCompras(
                                        context,
                                        alimento,
                                      );
                                    },
                                    tooltip: 'Ver compras realizadas',
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      _editarAlimento(context, alimento);
                                    },
                                    tooltip: 'Editar alimento',
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outlined,
                                      size: 22,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _eliminarAlimento(context, alimento);
                                    },
                                    tooltip: 'Eliminar alimento',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarHistorialCompras(BuildContext context, Alimento alimento) {
    // TODO: Implementar navegación a pantalla de historial de compras
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Historial de compras de: ${alimento.tipo}')),
    );
  }

  void _editarAlimento(BuildContext context, Alimento alimento) {
    // TODO: Implementar navegación a pantalla de edición
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editar: ${alimento.tipo}')));
  }

  void _eliminarAlimento(BuildContext context, Alimento alimento) async {
    // Mostrar diálogo de confirmación
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${alimento.tipo}"?\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      try {
        // Eliminar de la base de datos
        await DatabaseHelper().deleteAlimentoByTipo(alimento.tipo);

        // Refrescar la lista
        _cargarAlimentos();

        // Feedback de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${alimento.tipo}" eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Feedback de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al eliminar el alimento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

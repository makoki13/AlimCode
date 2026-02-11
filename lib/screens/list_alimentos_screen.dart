// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/alimento.dart';
import '../screens/editar_alimento_screen.dart';
import '../screens/historial_compras_screen.dart';
import '../screens/precio_compra_screen.dart'; // ← Import necesario para el nuevo botón

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
    _alimentosFuture = DatabaseHelper().getAlimentos();
    
    // Escuchar cambios en el campo de búsqueda para reconstruir la UI
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Alimento> _filtrarAlimentos(List<Alimento> alimentos, String query) {
    if (query.isEmpty) return alimentos;
    
    final queryLower = query.toLowerCase().trim();
    return alimentos.where((alimento) {
      return alimento.tipo.toLowerCase().contains(queryLower);
    }).toList();
  }

  void _limpiarBusqueda() {
    _searchController.clear();
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
                      hintText: 'Buscar por nombre...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: _limpiarBusqueda,
                              tooltip: 'Limpiar búsqueda',
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {});
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
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay alimentos guardados.'),
                  );
                }

                final alimentosFiltrados = _filtrarAlimentos(
                  snapshot.data!,
                  _searchController.text,
                );

                if (alimentosFiltrados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No se encontraron alimentos con el nombre "${_searchController.text}"'
                              : 'No hay alimentos guardados.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        if (_searchController.text.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _limpiarBusqueda,
                            child: const Text('Ver todos los alimentos'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: alimentosFiltrados.length,
                  itemBuilder: (context, index) {
                    final alimento = alimentosFiltrados[index];
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
                            // Subtítulo con preparación y cantidad
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
                                // Icono 1: Añadir compra (NUEVO - primero por la izquierda)
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_shopping_cart_outlined,
                                    size: 22,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    _anadirCompra(context, alimento);
                                  },
                                  tooltip: 'Añadir compra',
                                ),
                                const SizedBox(width: 8),
                                // Icono 2: Historial de compras
                                IconButton(
                                  icon: const Icon(
                                    Icons.receipt_outlined,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    _mostrarHistorialCompras(context, alimento);
                                  },
                                  tooltip: 'Ver compras realizadas',
                                ),
                                const SizedBox(width: 8),
                                // Icono 3: Editar
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
                                // Icono 4: Eliminar
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
              },
            ),
          ),
        ],
      ),
    );
  }

  void _anadirCompra(BuildContext context, Alimento alimento) async {
    // Abrir pantalla para introducir precio y registrar compra
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PrecioCompraScreen(
          tipoProducto: alimento.tipo,
        ),
      ),
    );
    
    // Si la compra se registró correctamente, mostrar feedback
    if (resultado == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Compra de "${alimento.tipo}" registrada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _mostrarHistorialCompras(BuildContext context, Alimento alimento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistorialComprasScreen(alimento: alimento),
      ),
    );
  }

  void _editarAlimento(BuildContext context, Alimento alimento) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarAlimentoScreen(alimento: alimento),
      ),
    );
    
    if (resultado == true) {
      _cargarAlimentos();
    }
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

        // Refrescar la lista completa
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
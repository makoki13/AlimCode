// lib/screens/historial_compras_screen.dart
import 'package:flutter/material.dart';
import '../models/alimento.dart';
import '../models/compra.dart';
import '../database/database_helper.dart';
import '../screens/precio_compra_screen.dart';

class HistorialComprasScreen extends StatefulWidget {
  final Alimento alimento;

  const HistorialComprasScreen({super.key, required this.alimento});

  @override
  State<HistorialComprasScreen> createState() => _HistorialComprasScreenState();
}

class _HistorialComprasScreenState extends State<HistorialComprasScreen> {
  late Future<List<Compra>> _comprasFuture;

  @override
  void initState() {
    super.initState();
    _cargarCompras();
  }

  void _cargarCompras() {
    setState(() {
      _comprasFuture = DatabaseHelper().getComprasPorAlimento(
        widget.alimento.tipo,
      );
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
        title: Text('Compras de ${widget.alimento.tipo}'),
      ),
      body: FutureBuilder<List<Compra>>(
        future: _comprasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final compras = snapshot.data ?? [];

            if (compras.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sin compras registradas',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aún no has registrado ninguna compra de "${widget.alimento.tipo}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _nuevaCompra,
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar primera compra'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: compras.length,
              itemBuilder: (context, index) {
                final compra = compras[index];
                return _buildCompraCard(compra, index == compras.length - 1);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildCompraCard(Compra compra, bool esUltima) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _formatearFecha(compra.fecha),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Precio
            Row(
              children: [
                Text(
                  '${compra.precio.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Botones de acción (modificar y eliminar)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    _modificarCompra(compra);
                  },
                  tooltip: 'Modificar compra',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outlined,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _eliminarCompra(compra);
                  },
                  tooltip: 'Eliminar compra',
                ),
              ],
            ),
            if (!esUltima) ...[const Divider(height: 1, thickness: 0.5)],
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return 'Hoy ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (diferencia.inDays == 1) {
      return 'Ayer ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (diferencia.inDays < 7) {
      return '${_nombreDia(fecha.weekday)} ${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    }
  }

  String _nombreDia(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mié';
      case 4:
        return 'Jue';
      case 5:
        return 'Vie';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }

  void _nuevaCompra() async {
    // Abrir pantalla para introducir precio
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PrecioCompraScreen(tipoProducto: widget.alimento.tipo),
      ),
    );

    // Si la compra se registró correctamente (resultado == true), recargar el historial
    if (resultado == true) {
      _cargarCompras();
    }
  }

  void _modificarCompra(Compra compra) {
    // TODO: Implementar funcionalidad de modificación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Modificar compra de ${compra.precio.toStringAsFixed(2)} €',
        ),
      ),
    );
  }

  void _eliminarCompra(Compra compra) {
    // TODO: Implementar funcionalidad de eliminación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Eliminar compra de ${compra.precio.toStringAsFixed(2)} €',
        ),
      ),
    );
  }
}

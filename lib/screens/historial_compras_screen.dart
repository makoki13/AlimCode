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
      _comprasFuture = DatabaseHelper().getComprasPorAlimentoId(
        widget.alimento.ID,
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
                    const SizedBox(height: 10),
                    Text(
                      '${widget.alimento.marca} ${widget.alimento.modelo}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
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
            // Información del producto
            Text(
              '${widget.alimento.tipo}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${widget.alimento.marca} ${widget.alimento.modelo}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Fecha y cantidad del producto
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _formatearFecha(compra.fecha),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Text(
                  '${widget.alimento.cantidad} ${widget.alimento.medida}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
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

  void _modificarCompra(Compra compra) async {
    // Mostrar diálogo para editar el precio
    final nuevoPrecio = await showDialog<double?>(
      context: context,
      builder: (context) => _EditarPrecioDialog(
        precioActual: compra.precio,
        titulo: 'Editar precio de compra',
        subtitulo: '${widget.alimento.tipo}\n${_formatearFecha(compra.fecha)}',
      ),
    );

    // Si el usuario confirmó la edición
    if (nuevoPrecio != null) {
      try {
        // Crear compra actualizada (manteniendo id, alimentoId y fecha originales)
        final compraActualizada = Compra(
          id: compra.id,
          alimentoId: compra.alimentoId,
          fecha: compra.fecha, // Mantener fecha original
          precio: nuevoPrecio,
        );

        // Actualizar en base de datos
        await DatabaseHelper().updateCompra(compraActualizada);

        // Recargar el historial
        _cargarCompras();

        // Feedback de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Precio actualizado a ${nuevoPrecio.toStringAsFixed(2)} €',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Feedback de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Error al guardar el precio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _eliminarCompra(Compra compra) async {
    // Mostrar diálogo de confirmación
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar esta compra de ${compra.precio.toStringAsFixed(2)} €?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    // Si el usuario confirma la eliminación
    if (confirmacion == true) {
      try {
        // Eliminar de la base de datos
        await DatabaseHelper().deleteCompra(compra.id);

        // Recargar el historial
        _cargarCompras();

        // Feedback de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Compra de ${compra.precio.toStringAsFixed(2)} € eliminada',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Feedback de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Error al eliminar la compra'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Diálogo personalizado para editar el precio
class _EditarPrecioDialog extends StatefulWidget {
  final double precioActual;
  final String titulo;
  final String subtitulo;

  const _EditarPrecioDialog({
    required this.precioActual,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  State<_EditarPrecioDialog> createState() => _EditarPrecioDialogState();
}

class _EditarPrecioDialogState extends State<_EditarPrecioDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.precioActual.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subtitulo,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Nuevo precio (€)',
                prefixIcon: const Icon(Icons.euro),
                border: const OutlineInputBorder(),
                helperText: 'Ej: 2.45',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un precio';
                }
                final precio = double.tryParse(value);
                if (precio == null || precio <= 0) {
                  return 'El precio debe ser mayor que 0';
                }
                if (precio > 1000) {
                  return '¿Precio realista? Revisa el valor';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                if (_formKey.currentState!.validate()) {
                  _guardar();
                }
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final nuevoPrecio = double.parse(_controller.text.trim());
      Navigator.of(context).pop(nuevoPrecio);
    }
  }
}

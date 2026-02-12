// lib/screens/editar_compra_screen.dart
import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class EditarCompraScreen extends StatefulWidget {
  final Compra compra;

  const EditarCompraScreen({super.key, required this.compra});

  @override
  State<EditarCompraScreen> createState() => _EditarCompraScreenState();
}

class _EditarCompraScreenState extends State<EditarCompraScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _precioController;
  String _nombreProducto = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _precioController = TextEditingController(
      text: widget.compra.precio.toStringAsFixed(2),
    );

    // Cargar el nombre del producto basado en el ID
    _cargarNombreProducto();
  }

  void _cargarNombreProducto() async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'alimentos',
        where: 'id = ?',
        whereArgs: [widget.compra.alimentoId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        setState(() {
          _nombreProducto = result.first['tipo'] as String;
        });
      } else {
        setState(() {
          _nombreProducto = 'Producto desconocido';
        });
      }
    } catch (e) {
      setState(() {
        _nombreProducto = 'Error al cargar producto';
      });
    }
  }

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
        ),
        title: const Text('Editar compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del producto original
              Text(
                'Producto: $_nombreProducto',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fecha: ${_formatearFecha(widget.compra.fecha)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Campo de precio
              TextFormField(
                controller: _precioController,
                enabled: !_isLoading,
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
                onSaved: (value) => _precioController.text = value!,
                onFieldSubmitted: (value) {
                  if (!_isLoading && _formKey.currentState!.validate()) {
                    _guardarCambios();
                  }
                },
              ),
              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context, false); // Cancelar
                            },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarCambios,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(fecha);
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final nuevoPrecio = double.parse(_precioController.text.trim());

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear compra actualizada (manteniendo id, alimentoId y fecha originales)
      final compraActualizada = Compra(
        id: widget.compra.id,
        alimentoId: widget.compra.alimentoId,
        fecha: widget.compra.fecha, // Mantener fecha original
        precio: nuevoPrecio,
      );

      // Actualizar en base de datos
      await DatabaseHelper().updateCompra(compraActualizada);

      // Feedback de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Precio actualizado a ${nuevoPrecio.toStringAsFixed(2)} €',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Volver indicando éxito
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// lib/screens/precio_compra_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:alimcode/models/alimento.dart';
import 'package:alimcode/models/bar.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/compra.dart';

class PrecioCompraScreen extends StatefulWidget {
  final String tipoProducto; // Nombre del producto para mostrar

  const PrecioCompraScreen({
    super.key,
    required this.tipoProducto,
  });

  @override
  State<PrecioCompraScreen> createState() => _PrecioCompraScreenState();
}

class _PrecioCompraScreenState extends State<PrecioCompraScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _precio;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Buscar el alimento completo para mostrar más detalles
    return FutureBuilder<List<Alimento>>(
      future: DatabaseHelper().getAlimentos(),
      builder: (context, snapshot) {
        Alimento? productoDetalle;
        if (snapshot.hasData) {
          productoDetalle = snapshot.data!.firstWhere(
            (alimento) => alimento.tipo == widget.tipoProducto,
            orElse: () => Alimento(
              ID: 0,
              tipo: widget.tipoProducto,
              marca: '',
              modelo: '',
              cantidad: 0.0,
              medida: '',
              bar: Bar(''),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (!_isLoading) {
                  Navigator.pop(context, false); // Cancelar sin guardar
                }
              },
            ),
            title: const Text('Registrar compra'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del producto
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productoDetalle?.tipo ?? widget.tipoProducto,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (productoDetalle?.marca != null && productoDetalle!.marca.isNotEmpty)
                          Text(
                            '${productoDetalle.marca} ${productoDetalle.modelo}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (productoDetalle != null && productoDetalle.cantidad > 0)
                          Text(
                            '${productoDetalle.cantidad} ${productoDetalle.medida}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Campo de precio
                  TextFormField(
                    enabled: !_isLoading,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Precio (€)',
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
                    onSaved: (value) => _precio = value,
                    onFieldSubmitted: (value) {
                      if (!_isLoading && _formKey.currentState!.validate()) {
                        _registrarCompra();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () {
                            Navigator.pop(context, false); // Cancelar
                          },
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _registrarCompra,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Registrar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _registrarCompra() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    final precio = double.parse(_precio!);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Crear y guardar la compra con fecha actual automática
      final compra = Compra(
        id: 0, // 0 para nuevo registro (AUTOINCREMENT lo asignará)
        tipoAlimento: widget.tipoProducto,
        fecha: DateTime.now(), // ← Fecha actual automática
        precio: precio,
      );
      
      await DatabaseHelper().insertCompra(compra);
      
      // Feedback de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compra registrada: ${widget.tipoProducto} - ${precio.toStringAsFixed(2)} €'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Volver a la pantalla anterior indicando éxito
      Navigator.pop(context, true);
      
    } catch (e) {
      // Feedback de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al registrar la compra'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }
}
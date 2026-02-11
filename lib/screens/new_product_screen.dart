// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/alimento.dart';
import '../models/bar.dart';
import '../database/database_helper.dart';

class NewProductScreen extends StatefulWidget {
  final Bar? bar; // Recibe opcionalmente el código de barras no encontrado

  const NewProductScreen({super.key, this.bar});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _tipo;
  String? _marca;
  String? _modelo;
  double? _cantidad;
  String? _medida;

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
        title: const Text('Nuevo Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo: Tipo (nombre del producto)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tipo (nombre del producto) *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el tipo';
                  }
                  return null;
                },
                onSaved: (value) => _tipo = value,
              ),
              const SizedBox(height: 16),
              // Campo: Marca
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Marca *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la marca';
                  }
                  return null;
                },
                onSaved: (value) => _marca = value,
              ),
              const SizedBox(height: 16),
              // Campo: Modelo (opcional)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Modelo/Variante',
                  hintText: 'Ej: Natural, Integral, Light...',
                  border: const OutlineInputBorder(),
                ),
                onSaved: (value) => _modelo = value,
              ),
              const SizedBox(height: 16),
              // Campo: Cantidad
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cantidad *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad';
                  }
                  final cantidad = double.tryParse(value);
                  if (cantidad == null || cantidad <= 0) {
                    return 'Cantidad debe ser mayor que 0';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    _cantidad = double.tryParse(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Campo: Medida
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Unidad de medida *',
                  hintText: 'Ej: g, ml, unidades, kg...',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la unidad de medida';
                  }
                  return null;
                },
                onSaved: (value) => _medida = value,
              ),
              const SizedBox(height: 24),
              // Botón de guardar
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Verificar si el código de barras ya existe
                    if (widget.bar != null) {
                      final existe = await DatabaseHelper().existeCodigoBarras(
                        widget.bar!.codigo,
                      );
                      if (existe) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '⚠️ El código de barras ${widget.bar!.codigo} ya está registrado para otro producto',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                    }

                    // Creamos el objeto Alimento
                    final alimento = Alimento(
                      ID: 0, // ID se generará automáticamente en la base de datos
                      tipo: _tipo!,
                      marca: _marca!,
                      modelo: _modelo ?? '',
                      cantidad: _cantidad ?? 0.0,
                      medida: _medida!,
                      bar:
                          widget.bar ??
                          Bar(
                            '0000000000000',
                          ), // Usamos el código de barras recibido
                    );

                    // Guardamos en la base de datos
                    final dbHelper = DatabaseHelper();
                    try {
                      await dbHelper.insertAlimento(alimento);

                      // Mostrar mensaje de éxito
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Producto guardado correctamente en la base de datos.',
                          ),
                        ),
                      );

                      // Volver a la pantalla anterior
                      Navigator.pop(context);
                    } catch (e) {
                      // Mostrar mensaje de error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al guardar el producto: $e'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

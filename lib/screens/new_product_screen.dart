import 'package:alimcode/models/alimento.dart';
import 'package:flutter/material.dart';
import '../models/bar.dart';

class NewProductScreen extends StatefulWidget {
  final Bar? bar; // Recibe opcionalmente el código de barras no encontrado

  const NewProductScreen({super.key, this.bar});

  @override
  State<NewProductScreen> createState() => _NewProductFormScreenState();
}

class _NewProductFormScreenState extends State<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _tipo;
  String? _preparacion;
  double? _cantidad;

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
              // Campo: Preparación (fresco, congelado, etc.)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Preparación (ej: fresco, congelado, enlatado)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _preparacion = value,
              ),
              const SizedBox(height: 16),
              // Campo: Cantidad
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cantidad en la unidad de compra',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    _cantidad = double.tryParse(value);
                  }
                },
              ),
              const SizedBox(height: 24),
              // Botón de guardar
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Creamos el objeto Alimento
                    final alimento = Alimento(
                      tipo: _tipo!,
                      preparacion: _preparacion ?? '',
                      cantidad: _cantidad ?? 0.0,
                      bar:
                          widget.bar ??
                          Bar(''), // Usamos el código de barras recibido
                    );

                    // Aquí puedes agregar la lógica para guardar el alimento
                    // Por ahora solo imprimimos los valores
                    print('Tipo: ${alimento.tipo}');
                    print('Preparación: ${alimento.preparacion}');
                    print('Cantidad: ${alimento.cantidad}');
                    print('Código de barras: ${alimento.bar.codigo}');

                    // Opcional: Mostrar un mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Producto guardado correctamente.'),
                      ),
                    );

                    // Volver a la pantalla anterior
                    Navigator.pop(context);
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

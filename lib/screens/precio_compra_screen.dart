import 'package:flutter/material.dart';

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
        title: const Text('Precio de compra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Producto: ${widget.tipoProducto}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Precio de la última compra',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
                onSaved: (value) => _precio = value,
                onFieldSubmitted: (value) {
                  // Al pulsar Enter, se cierra la ventana si es válido
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, double.parse(_precio!));
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, double.parse(_precio!));
                  }
                },
                child: const Text('Guardar Precio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
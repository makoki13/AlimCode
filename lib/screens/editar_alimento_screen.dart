// lib/screens/editar_alimento_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/alimento.dart';
import '../database/database_helper.dart';

class EditarAlimentoScreen extends StatefulWidget {
  final Alimento alimento;

  const EditarAlimentoScreen({super.key, required this.alimento});

  @override
  State<EditarAlimentoScreen> createState() => _EditarAlimentoScreenState();
}

class _EditarAlimentoScreenState extends State<EditarAlimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tipoController;
  late TextEditingController _preparacionController;
  late TextEditingController _cantidadController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tipoController = TextEditingController(text: widget.alimento.tipo);
    _preparacionController = TextEditingController(
      text: widget.alimento.preparacion,
    );
    _cantidadController = TextEditingController(
      text: widget.alimento.cantidad.toString(),
    );
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _preparacionController.dispose();
    _cantidadController.dispose();
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
        title: const Text('Editar alimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo (nombre)
              TextFormField(
                controller: _tipoController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Nombre del alimento *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Preparación
              TextFormField(
                controller: _preparacionController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Preparación',
                  helperText: 'Ej: Fresco, Congelado, Cocido...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Cantidad
              TextFormField(
                controller: _cantidadController,
                enabled: !_isLoading,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cantidad *',
                  helperText: 'Ej: 1000 (gramos/ml)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La cantidad es obligatoria';
                  }
                  final cantidad = double.tryParse(value.trim());
                  if (cantidad == null || cantidad <= 0) {
                    return 'Cantidad debe ser mayor que 0';
                  }
                  return null;
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
                          : () => Navigator.pop(context, false),
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

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    // Obtener valores limpios
    final tipoNuevo = _tipoController.text.trim();
    final preparacionNueva = _preparacionController.text.trim();
    final cantidadNueva = double.parse(_cantidadController.text.trim());

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear alimento actualizado (manteniendo el código de barras original)
      final alimentoActualizado = Alimento(
        tipo: tipoNuevo,
        preparacion: preparacionNueva,
        cantidad: cantidadNueva,
        bar: widget.alimento.bar, // ← Mantener el código de barras original
      );

      // Actualizar en base de datos
      await DatabaseHelper().updateAlimento(
        widget.alimento.tipo, // tipo antiguo (clave)
        alimentoActualizado,
      );

      // Feedback de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "$tipoNuevo" actualizado correctamente'),
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

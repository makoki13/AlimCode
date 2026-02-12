// lib/screens/editar_alimento_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/alimento.dart';
import '../models/bar.dart';
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
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _cantidadController;
  late TextEditingController _medidaController;
  late TextEditingController _codigoBarrasController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tipoController = TextEditingController(text: widget.alimento.tipo);
    _marcaController = TextEditingController(text: widget.alimento.marca);
    _modeloController = TextEditingController(text: widget.alimento.modelo);
    _cantidadController = TextEditingController(text: widget.alimento.cantidad.toString());
    _medidaController = TextEditingController(text: widget.alimento.medida);
    _codigoBarrasController = TextEditingController(text: widget.alimento.bar.codigo);
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _cantidadController.dispose();
    _medidaController.dispose();
    _codigoBarrasController.dispose();
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

              // Marca
              TextFormField(
                controller: _marcaController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Marca *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La marca es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Modelo
              TextFormField(
                controller: _modeloController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Modelo/Variante',
                  helperText: 'Ej: Natural, Integral, Light...',
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
                  helperText: 'Ej: 500',
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
              const SizedBox(height: 16),

              // Medida
              TextFormField(
                controller: _medidaController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Unidad de medida *',
                  helperText: 'Ej: g, ml, unidades, kg...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La unidad de medida es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Código de barras
              TextFormField(
                controller: _codigoBarrasController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Código de barras *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El código de barras es obligatorio';
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
                      onPressed: _isLoading ? null : () => Navigator.pop(context, false),
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
    final marcaNueva = _marcaController.text.trim();
    final modeloNuevo = _modeloController.text.trim();
    final cantidadNueva = double.parse(_cantidadController.text.trim());
    final medidaNueva = _medidaController.text.trim();
    final codigoNuevo = _codigoBarrasController.text.trim();

    // Verificar si el código de barras ya existe para OTRO alimento
    if (codigoNuevo != widget.alimento.bar.codigo) {
      final existe = await DatabaseHelper().existeCodigoBarras(codigoNuevo);
      if (existe) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Este código de barras ya está registrado para otro alimento'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear alimento actualizado
      final alimentoActualizado = Alimento(
        ID: widget.alimento.ID, // Mantener el ID original
        tipo: tipoNuevo,
        marca: marcaNueva,
        modelo: modeloNuevo,
        cantidad: cantidadNueva,
        medida: medidaNueva,
        bar: Bar(codigoNuevo),
      );

      // Actualizar en base de datos
      await DatabaseHelper().updateAlimentoById(
        widget.alimento.ID, // usar ID para actualizar
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
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/alimento.dart';

class ListAlimentosScreen extends StatefulWidget {
  const ListAlimentosScreen({super.key});

  @override
  State<ListAlimentosScreen> createState() => _ListAlimentosScreenState();
}

class _ListAlimentosScreenState extends State<ListAlimentosScreen> {
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
      body: FutureBuilder<List<Alimento>>(
        future: DatabaseHelper().getAlimentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final alimentos = snapshot.data ?? [];
            if (alimentos.isEmpty) {
              return const Center(child: Text('No hay alimentos guardados.'));
            }
            return ListView.builder(
              itemCount: alimentos.length,
              itemBuilder: (context, index) {
                final alimento = alimentos[index];
                return Card(
                  child: ListTile(
                    title: Text(alimento.tipo),
                    subtitle: Text(
                      'Preparación: ${alimento.preparacion}\nCant: ${alimento.cantidad}\nCód: ${alimento.bar.codigo}',
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
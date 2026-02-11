// lib/models/alimento.dart
import 'bar.dart';

class Alimento {
  final int ID;
  final String tipo;
  final String marca;
  final String modelo;
  final double cantidad;
  final String medida;
  final Bar bar;

  Alimento({
    required this.ID,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.cantidad,
    required this.medida,
    required this.bar,
  });

  // Constructor para crear desde mapa (base de datos)
  factory Alimento.fromMap(Map<String, dynamic> map) {
    return Alimento(
      ID: map['id'] ?? 0,
      tipo: map['tipo'] ?? '',
      marca: map['marca'] ?? '',
      modelo: map['modelo'] ?? '',
      cantidad: (map['cantidad'] as num?)?.toDouble() ?? 0.0,
      medida: map['medida'] ?? '',
      bar: Bar(map['codigo_barras'] ?? ''),
    );
  }

  // Método para convertir a mapa (para guardar en base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': ID,
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'cantidad': cantidad,
      'medida': medida,
      'codigo_barras': bar.codigo,
    };
  }

  // Método para crear una copia con campos modificados (útil para edición)
  Alimento copyWith({
    int? ID,
    String? tipo,
    String? marca,
    String? modelo,
    double? cantidad,
    String? medida,
    Bar? bar,
  }) {
    return Alimento(
      ID: ID ?? this.ID,
      tipo: tipo ?? this.tipo,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      cantidad: cantidad ?? this.cantidad,
      medida: medida ?? this.medida,
      bar: bar ?? this.bar,
    );
  }
}
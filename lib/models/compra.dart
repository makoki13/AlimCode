// lib/models/compra.dart
class Compra {
  final int id;
  final String tipoAlimento; // Relación con Alimento.tipo
  final DateTime fecha;
  final double precio;

  Compra({
    required this.id,
    required this.tipoAlimento,
    required this.fecha,
    required this.precio,
  });

  // Constructor para crear desde mapa (base de datos)
  factory Compra.fromMap(Map<String, dynamic> map) {
    return Compra(
      id: map['id'] ?? 0,
      tipoAlimento: map['tipo_alimento'] ?? '',
      fecha: DateTime.tryParse(map['fecha']?.toString() ?? '') ?? DateTime.now(),
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Método para convertir a mapa (para guardar en base de datos)
  Map<String, dynamic> toMap() {
    // IMPORTANTE: Para nuevos registros (id <= 0), NO incluir el campo 'id'
    // Así SQLite genera automáticamente un nuevo ID con AUTOINCREMENT
    final map = <String, dynamic>{
      'tipo_alimento': tipoAlimento,
      'fecha': fecha.toIso8601String(),
      'precio': precio,
    };
    
    // Solo incluir 'id' si es un registro existente (id > 0)
    if (id > 0) {
      map['id'] = id;
    }
    
    return map;
  }

  // Método para crear una copia con campos modificados (útil para edición)
  Compra copyWith({
    int? id,
    String? tipoAlimento,
    DateTime? fecha,
    double? precio,
  }) {
    return Compra(
      id: id ?? this.id,
      tipoAlimento: tipoAlimento ?? this.tipoAlimento,
      fecha: fecha ?? this.fecha,
      precio: precio ?? this.precio,
    );
  }
}
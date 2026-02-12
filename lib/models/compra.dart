// lib/models/compra.dart
class Compra {
  final int id;
  final int alimentoId; // ID del alimento
  final DateTime fecha;
  final double precio;

  Compra({
    required this.id,
    required this.alimentoId,
    required this.fecha,
    required this.precio,
  });

  // Constructor para crear desde mapa (base de datos)
  factory Compra.fromMap(Map<String, dynamic> map) {
    return Compra(
      id: map['id'] ?? 0,
      alimentoId: map['alimento_id'] as int? ?? 0,
      fecha: DateTime.tryParse(map['fecha']?.toString() ?? '') ?? DateTime.now(),
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Constructor para crear desde mapa con ID de alimento explícito
  factory Compra.fromMapWithId(Map<String, dynamic> map, [int? providedAlimentoId]) {
    return Compra(
      id: map['id'] ?? 0,
      alimentoId: map['alimento_id'] as int? ?? providedAlimentoId ?? 0,
      fecha: DateTime.tryParse(map['fecha']?.toString() ?? '') ?? DateTime.now(),
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Constructor para crear una nueva compra (sin ID)
  factory Compra.nueva({
    required int alimentoId,
    required DateTime fecha,
    required double precio,
  }) {
    return Compra(
      id: 0, // 0 indica nuevo registro
      alimentoId: alimentoId,
      fecha: fecha,
      precio: precio,
    );
  }

  // Método para convertir a mapa (para guardar en base de datos)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'alimento_id': alimentoId,
      'fecha': fecha.toIso8601String(),
      'precio': precio,
    };
    
    if (id > 0) {
      map['id'] = id;
    }
    
    return map;
  }

  // Método para crear una copia con campos modificados
  Compra copyWith({
    int? id,
    int? alimentoId,
    DateTime? fecha,
    double? precio,
  }) {
    return Compra(
      id: id ?? this.id,
      alimentoId: alimentoId ?? this.alimentoId,
      fecha: fecha ?? this.fecha,
      precio: precio ?? this.precio,
    );
  }
}
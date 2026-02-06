import '../models/bar.dart';
import '../models/alimento.dart'; // Importamos Alimento
import '../database/database_helper.dart';

abstract class LocalService {
  Future<Alimento?> obtenerProducto(Bar bar); // Retorna Alimento o null
}

// Implementación real con SQLite
class SQLiteLocalService implements LocalService {
  @override
  Future<Alimento?> obtenerProducto(Bar bar) async {
    try {
      final dbHelper = DatabaseHelper();
      final alimentos = await dbHelper.getAlimentosPorCodigo(bar.codigo);

      if (alimentos.isNotEmpty) {
        return alimentos.first; // Devolvemos el primer resultado
      } else {
        return null; // No se encontró
      }
    } catch (e) {
      print('Error al buscar producto en la base de datos: $e');
      return null;
    }
  }
}

// Por ahora usamos una implementación simulada
class MockLocalService implements LocalService {
  @override
  Future<Alimento?> obtenerProducto(Bar bar) async {
    // Simulamos que por ahora no existe en la base de datos local
    return null;
  }
}
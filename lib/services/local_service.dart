import '../models/bar.dart';

abstract class LocalService {
  Future<bool> existeProducto(Bar bar);
}

// Por ahora usamos una implementación simulada
class MockLocalService implements LocalService {
  @override
  Future<bool> existeProducto(Bar bar) async {
    // Simulamos que por ahora no existe en la base de datos local
    return false;
  }
}
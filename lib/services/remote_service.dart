import '../models/alimento.dart';
import '../models/bar.dart';

abstract class RemoteService {
  Future<Alimento?> busca(Bar bar);
}

// Por ahora creamos una implementación simulada
class OpenFoodFactsService implements RemoteService {
  @override
  Future<Alimento?> busca(Bar bar) async {
    // Simulamos que buscamos en Open Food Facts
    // Si encontramos el producto, devolvemos un Alimento, sino null
    // Por ahora, devolvemos null para todos
    return null;
  }
}
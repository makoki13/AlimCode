import '../models/alimento.dart';

class BarItems {
  //static final LocalService _localService = SQLiteLocalService();
  //static final RemoteService _remoteService = OpenFoodFactsService();

  /// Devuelve `true` si el código de barras existe en la base de datos local, `false` en caso contrario.
  /* static Future<bool> existeBar(Bar bar) async {
    // Paso 1: Verificar en la base de datos local
    if (await _localService.obtenerProducto(bar)) {
      return true;
    }

    // Paso 2: Verificar en servicios remotos (por ejemplo, Open Food Facts)
    final alimento = await _remoteService.busca(bar);
    if (alimento != null) {
      // Si se encontró en remoto, podrías guardarlo en local aquí (opcional)
      // await _localService.guardarProducto(alimento);
      return true;
    }

    // Paso 3: Si no se encuentra en ninguno, devolver false
    return false;
  } */

  /// Añade un alimento a la base de datos local.
  /// Devuelve `true` si la operación fue exitosa, `false` en caso contrario.
  static Future<bool> addBar(Alimento alimento) async {
    // TODO: Implementar lógica de inserción en SQLite
    return false; // Valor por defecto
  }
}
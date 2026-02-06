import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/alimento.dart';
import '../models/bar.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'alimentos.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alimentos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        preparacion TEXT,
        cantidad REAL NOT NULL,
        codigo_barras TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertAlimento(Alimento alimento) async {
    /* print('Insertando alimento:');
    print('Tipo: ${alimento.tipo}');
    print('Preparación: ${alimento.preparacion}');
    print('Cantidad: ${alimento.cantidad}');
    print(
      'Código de barras: "${alimento.bar.codigo}"',
    ); */ // ← Agrega comillas para ver si es vacío
    final db = await database;
    return await db.insert('alimentos', {
      'tipo': alimento.tipo,
      'preparacion': alimento.preparacion,
      'cantidad': alimento.cantidad,
      'codigo_barras': alimento.bar.codigo,
    });
  }

  Future<List<Alimento>> getAlimentos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('alimentos');

    return List.generate(maps.length, (i) {
      return Alimento(
        tipo: maps[i]['tipo'],
        preparacion: maps[i]['preparacion'],
        cantidad: maps[i]['cantidad'],
        bar: Bar(maps[i]['codigo_barras']),
      );
    });
  }

  Future<bool> existeCodigoBarras(String codigo) async {
    final db = await database;
    final result = await db.query(
      'alimentos',
      where: 'codigo_barras = ?',
      whereArgs: [codigo],
    );
    return result.isNotEmpty;
  }

  // Método para obtener alimentos por código de barras
  Future<List<Alimento>> getAlimentosPorCodigo(String codigo) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'alimentos',
      where: 'codigo_barras = ?',
      whereArgs: [codigo],
    );

    return List.generate(maps.length, (i) {
      return Alimento(
        tipo: maps[i]['tipo'],
        preparacion: maps[i]['preparacion'],
        cantidad: maps[i]['cantidad'],
        bar: Bar(maps[i]['codigo_barras']),
      );
    });
  }
}

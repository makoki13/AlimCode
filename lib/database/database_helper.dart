import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/alimento.dart';
import '../models/bar.dart';
import '../models/compra.dart';

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
    return await openDatabase(
      path,
      version: 2, // Incrementado a versión 2 para incluir tabla 'compras'
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de alimentos
    await db.execute('''
      CREATE TABLE alimentos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL UNIQUE,
        preparacion TEXT,
        cantidad REAL NOT NULL,
        codigo_barras TEXT NOT NULL
      )
    ''');

    // Crear tabla de compras
    await db.execute('''
      CREATE TABLE compras(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo_alimento TEXT NOT NULL,
        fecha TEXT NOT NULL,
        precio REAL NOT NULL,
        FOREIGN KEY (tipo_alimento) REFERENCES alimentos(tipo) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Crear tabla de compras al actualizar de versión 1 a 2
      await db.execute('''
        CREATE TABLE compras(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tipo_alimento TEXT NOT NULL,
          fecha TEXT NOT NULL,
          precio REAL NOT NULL,
          FOREIGN KEY (tipo_alimento) REFERENCES alimentos(tipo) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<int> insertAlimento(Alimento alimento) async {
    final db = await database;
    return await db.insert('alimentos', {
      'tipo': alimento.tipo,
      'preparacion': alimento.preparacion,
      'cantidad': alimento.cantidad,
      'codigo_barras': alimento.bar.codigo,
    });
  }

  Future<int> deleteAlimentoByTipo(String tipo) async {
    final db = await database;

    // Primero eliminar las compras asociadas para mantener integridad referencial
    await db.delete('compras', where: 'tipo_alimento = ?', whereArgs: [tipo]);

    // Luego eliminar el alimento
    return await db.delete('alimentos', where: 'tipo = ?', whereArgs: [tipo]);
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

  // === MÉTODOS PARA COMPRAS ===

  Future<List<Compra>> getComprasPorAlimento(String tipoAlimento) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'compras',
      where: 'tipo_alimento = ?',
      whereArgs: [tipoAlimento],
      orderBy: 'fecha DESC',
    );

    return List.generate(maps.length, (i) => Compra.fromMap(maps[i]));
  }

  Future<int> insertCompra(Compra compra) async {
    final db = await database;

    return await db.insert(
      'compras',
      compra.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteCompra(int id) async {
    final db = await database;

    return await db.delete('compras', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteComprasPorAlimento(String tipoAlimento) async {
    final db = await database;

    return await db.delete(
      'compras',
      where: 'tipo_alimento = ?',
      whereArgs: [tipoAlimento],
    );
  }

  Future<List<Compra>> getAllCompras() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'compras',
      orderBy: 'fecha DESC',
    );

    return List.generate(maps.length, (i) => Compra.fromMap(maps[i]));
  }

  // En lib/database/database_helper.dart
  Future<int> updateCompra(Compra compra) async {
    final db = await database;

    return await db.update(
      'compras',
      compra.toMap(), // toMap() debe incluir el 'id' ya que es > 0
      where: 'id = ?',
      whereArgs: [compra.id],
    );
  }

  Future<int> updateAlimento(
    String tipoAntiguo,
    Alimento alimentoActualizado,
  ) async {
    final db = await database;

    // Verificar si el nuevo tipo ya existe para otro alimento
    if (tipoAntiguo != alimentoActualizado.tipo) {
      final existe = await db.query(
        'alimentos',
        where: 'tipo = ?',
        whereArgs: [alimentoActualizado.tipo],
      );
      if (existe.isNotEmpty) {
        throw Exception(
          'Ya existe un alimento con el nombre "${alimentoActualizado.tipo}"',
        );
      }
    }

    // Actualizar el alimento
    final rowsAffected = await db.update(
      'alimentos',
      {
        'tipo': alimentoActualizado.tipo,
        'preparacion': alimentoActualizado.preparacion,
        'cantidad': alimentoActualizado.cantidad,
        'codigo_barras': alimentoActualizado.bar.codigo,
      },
      where: 'tipo = ?',
      whereArgs: [tipoAntiguo],
    );

    // Si el tipo cambió, actualizar también las compras asociadas
    if (tipoAntiguo != alimentoActualizado.tipo) {
      await db.update(
        'compras',
        {'tipo_alimento': alimentoActualizado.tipo},
        where: 'tipo_alimento = ?',
        whereArgs: [tipoAntiguo],
      );
    }

    return rowsAffected;
  }
}

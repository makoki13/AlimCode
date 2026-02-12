import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/alimento.dart';
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
      version:
          5, // Incrementado a versión 5 para quitar UNIQUE de codigo_barras
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de alimentos con la nueva estructura (sin UNIQUE en codigo_barras)
    await db.execute('''
      CREATE TABLE alimentos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        marca TEXT NOT NULL,
        modelo TEXT NOT NULL,
        cantidad REAL NOT NULL,
        medida TEXT NOT NULL,
        codigo_barras TEXT NOT NULL
      )
    ''');

    // Crear tabla de compras con clave foránea por ID de alimento
    await db.execute('''
      CREATE TABLE compras(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        alimento_id INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        precio REAL NOT NULL,
        FOREIGN KEY (alimento_id) REFERENCES alimentos(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Crear tabla de compras (migración v1 → v2)
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

    if (oldVersion < 3) {
      // Migrar tabla de alimentos a nueva estructura (v2 → v3)
      // 1. Renombrar tabla actual
      await db.execute('ALTER TABLE alimentos RENAME TO alimentos_old');

      // 2. Crear nueva tabla con estructura completa
      await db.execute('''
        CREATE TABLE alimentos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tipo TEXT NOT NULL,
          marca TEXT NOT NULL DEFAULT '',
          modelo TEXT NOT NULL DEFAULT '',
          cantidad REAL NOT NULL DEFAULT 0.0,
          medida TEXT NOT NULL DEFAULT '',
          codigo_barras TEXT NOT NULL
        )
      ''');

      // 3. Copiar datos de la tabla antigua a la nueva (llenando campos nuevos con valores por defecto)
      await db.execute('''
        INSERT INTO alimentos (id, tipo, marca, modelo, cantidad, medida, codigo_barras)
        SELECT 
          id,
          tipo,
          CASE WHEN marca IS NULL THEN '' ELSE marca END,
          CASE WHEN modelo IS NULL THEN '' ELSE modelo END,
          cantidad,
          CASE WHEN medida IS NULL THEN '' ELSE medida END,
          codigo_barras
        FROM alimentos_old
      ''');

      // 4. Eliminar tabla antigua
      await db.execute('DROP TABLE alimentos_old');
    }

    if (oldVersion < 4) {
      // Migrar tabla de compras para usar ID en lugar de tipo (v3 → v4)
      // 1. Renombrar tabla actual
      await db.execute('ALTER TABLE compras RENAME TO compras_old');

      // 2. Crear nueva tabla con clave foránea por ID
      await db.execute('''
        CREATE TABLE compras(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          alimento_id INTEGER NOT NULL,
          fecha TEXT NOT NULL,
          precio REAL NOT NULL,
          FOREIGN KEY (alimento_id) REFERENCES alimentos(id) ON DELETE CASCADE
        )
      ''');

      // 3. Copiar datos, convirtiendo tipo_alimento a alimento_id
      await db.execute('''
        INSERT INTO compras (id, alimento_id, fecha, precio)
        SELECT 
          co.id,
          a.id,
          co.fecha,
          co.precio
        FROM compras_old co
        JOIN alimentos a ON a.tipo = co.tipo_alimento
      ''');

      // 4. Eliminar tabla antigua
      await db.execute('DROP TABLE compras_old');
    }

    if (oldVersion < 5) {
      // Migrar tabla de alimentos para quitar UNIQUE de codigo_barras (v4 → v5)
      // 1. Renombrar tabla actual
      await db.execute('ALTER TABLE alimentos RENAME TO alimentos_old');

      // 2. Crear nueva tabla sin UNIQUE en codigo_barras
      await db.execute('''
        CREATE TABLE alimentos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tipo TEXT NOT NULL,
          marca TEXT NOT NULL,
          modelo TEXT NOT NULL,
          cantidad REAL NOT NULL,
          medida TEXT NOT NULL,
          codigo_barras TEXT NOT NULL
        )
      ''');

      // 3. Copiar datos
      await db.execute('''
        INSERT INTO alimentos (id, tipo, marca, modelo, cantidad, medida, codigo_barras)
        SELECT id, tipo, marca, modelo, cantidad, medida, codigo_barras
        FROM alimentos_old
      ''');

      // 4. Eliminar tabla antigua
      await db.execute('DROP TABLE alimentos_old');
    }
  }

  // Insertar nuevo alimento
  Future<int> insertAlimento(Alimento alimento) async {
    final db = await database;
    return await db.insert('alimentos', alimento.toMap());
  }

  // Eliminar alimento por ID
  Future<int> deleteAlimentoById(int id) async {
    final db = await database;
    // Eliminar primero las compras asociadas
    await db.delete('compras', where: 'alimento_id = ?', whereArgs: [id]);
    // Luego eliminar el alimento
    return await db.delete('alimentos', where: 'id = ?', whereArgs: [id]);
  }

  // Eliminar alimento por tipo (método antiguo mantenido para compatibilidad)
  Future<int> deleteAlimentoByTipo(String tipo) async {
    final db = await database;

    // Obtener el ID del alimento por tipo
    final alimentoResult = await db.query(
      'alimentos',
      where: 'tipo = ?',
      whereArgs: [tipo],
      limit: 1,
    );

    if (alimentoResult.isEmpty) {
      return 0; // No se encontró el alimento
    }

    final alimentoId = alimentoResult.first['id'] as int;

    // Eliminar primero las compras asociadas
    await db.delete(
      'compras',
      where: 'alimento_id = ?',
      whereArgs: [alimentoId],
    );

    // Luego eliminar el alimento
    return await db.delete('alimentos', where: 'tipo = ?', whereArgs: [tipo]);
  }

  // Obtener todos los alimentos
  Future<List<Alimento>> getAlimentos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('alimentos');

    return List.generate(maps.length, (i) => Alimento.fromMap(maps[i]));
  }

  // Actualizar alimento por ID
  Future<int> updateAlimentoById(int id, Alimento alimentoActualizado) async {
    final db = await database;

    // Actualizar el alimento
    final rowsAffected = await db.update(
      'alimentos',
      alimentoActualizado.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    return rowsAffected;
  }

  // Actualizar alimento por tipo (método antiguo mantenido para compatibilidad)
  Future<int> updateAlimento(
    String tipoAntiguo,
    Alimento alimentoActualizado,
  ) async {
    final db = await database;

    // Verificar si el tipo cambia y si el nuevo ya existe
    if (tipoAntiguo != alimentoActualizado.tipo) {
      final existe = await db.query(
        'alimentos',
        where: 'tipo = ? AND tipo != ?',
        whereArgs: [alimentoActualizado.tipo, tipoAntiguo],
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
      alimentoActualizado.toMap(),
      where: 'tipo = ?',
      whereArgs: [tipoAntiguo],
    );

    return rowsAffected;
  }

  // Método para verificar si existe código de barras
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

    return List.generate(maps.length, (i) => Alimento.fromMap(maps[i]));
  }

  // === MÉTODOS PARA COMPRAS ===

  Future<List<Compra>> getComprasPorAlimento(String tipoAlimento) async {
    final db = await database;

    // Primero obtener el ID del alimento
    final alimentoResult = await db.query(
      'alimentos',
      where: 'tipo = ?',
      whereArgs: [tipoAlimento],
      limit: 1,
    );

    if (alimentoResult.isEmpty) {
      return []; // No se encontró el alimento
    }

    final alimentoId = alimentoResult.first['id'] as int;

    return await getComprasPorAlimentoId(alimentoId);
  }

  Future<List<Compra>> getComprasPorAlimentoId(int alimentoId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'compras',
      where: 'alimento_id = ?',
      whereArgs: [alimentoId],
      orderBy: 'fecha DESC',
    );

    return List.generate(
      maps.length,
      (i) => Compra.fromMapWithId(maps[i], alimentoId),
    );
  }

  // En database_helper.dart, actualizar el método insertCompra:

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

    // Primero obtener el ID del alimento
    final alimentoResult = await db.query(
      'alimentos',
      where: 'tipo = ?',
      whereArgs: [tipoAlimento],
      limit: 1,
    );

    if (alimentoResult.isEmpty) {
      return 0; // No se encontró el alimento
    }

    final alimentoId = alimentoResult.first['id'] as int;

    return await db.delete(
      'compras',
      where: 'alimento_id = ?',
      whereArgs: [alimentoId],
    );
  }

  Future<List<Compra>> getAllCompras() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'compras',
      orderBy: 'fecha DESC',
    );

    return List.generate(maps.length, (i) => Compra.fromMapWithId(maps[i]));
  }

  // En database_helper.dart, actualizar el método updateCompra:

  Future<int> updateCompra(Compra compra) async {
    final db = await database;

    return await db.update(
      'compras',
      compra.toMap(),
      where: 'id = ?',
      whereArgs: [compra.id],
    );
  }
}

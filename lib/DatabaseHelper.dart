import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'game_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_data (
        id INTEGER PRIMARY KEY,
        collectedStones INTEGER,
        stonesPerClick INTEGER,
        autoClickers INTEGER,
        materialsUnlocked INTEGER,
        clickUpgradeLevel INTEGER,
        autoClickerUpgradeLevel INTEGER,
        materialUpgradeLevel INTEGER
      )
    ''');

    // Inserisci i valori iniziali
    await db.insert('game_data', {
      'collectedStones': 0,
      'stonesPerClick': 1,
      'autoClickers': 0,
      'materialsUnlocked': 0,
      'clickUpgradeLevel': 5,
      'autoClickerUpgradeLevel': 5,
      'materialUpgradeLevel': 5,
    });
  }

  // Funzione per ottenere i dati
  Future<Map<String, dynamic>> getGameData() async {
    final db = await database;
    List<Map<String, dynamic>> result =
        await db.query('game_data', where: 'id = ?', whereArgs: [1]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {};
    }
  }

  // Funzione per salvare i dati
  Future<void> saveGameData(Map<String, dynamic> data) async {
    final db = await database;
    await db.update('game_data', data, where: 'id = ?', whereArgs: [1]);
  }
}

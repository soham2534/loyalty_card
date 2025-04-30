import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../../shared/models/card_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  static Database? _database;

  factory LocalDatabaseService() => _instance;

  LocalDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Web platform initialization
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        'loyalty_cards.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDatabase,
        ),
      );
    } else {
      // Native platform initialization
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'loyalty_cards.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
      );
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cards(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        cardNumber TEXT NOT NULL,
        barcode TEXT,
        qrCode TEXT,
        expiryDate TEXT,
        imagePath TEXT,
        notes TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertCard(CardModel card) async {
    final db = await database;
    return await db.insert('cards', card.toJson());
  }

  Future<List<CardModel>> getAllCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cards');
    return List.generate(maps.length, (i) => CardModel.fromJson(maps[i]));
  }

  Future<CardModel?> getCardById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CardModel.fromJson(maps.first);
  }

  Future<int> updateCard(CardModel card) async {
    final db = await database;
    return await db.update(
      'cards',
      card.toJson(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(String id) async {
    final db = await database;
    return await db.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CardModel>> getFavoriteCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => CardModel.fromJson(maps[i]));
  }

  Future<List<CardModel>> searchCards(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'name LIKE ? OR cardNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => CardModel.fromJson(maps[i]));
  }

  Future<List<CardModel>> getExpiringCards() async {
    final db = await database;
    final now = DateTime.now();
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'expiryDate IS NOT NULL AND expiryDate > ?',
      whereArgs: [now.toIso8601String()],
    );
    return List.generate(maps.length, (i) => CardModel.fromJson(maps[i]));
  }
} 
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class ContactRepository {
  static final ContactRepository _contactService =
      ContactRepository._internal();

  factory ContactRepository() => _contactService;

  ContactRepository._internal();

  Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await initDatabase();
      return _database;
    }
  }

  Future<Database> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contacts.db");

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
        "CREATE TABLE contact ("
        "id INTEGER PRIMARY KEY,"
        "name TEXT,"
        "email TEXT,"
        "phone TEXT,"
        "image TEXT"
        ")",
      );
    });
  }

  Future<int?> save(Contact contact) async {
    final db = await database;
    await db?.insert('contact', contact.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Contact>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('contact');
    return List.generate(maps.length, (index) {
      return Contact.fromJson(maps[index]);
    });
  }

  Future<Contact?> getById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'contact',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Contact.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<Contact?> getByPhone(String phone) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'contact',
      where: 'phone = ?',
      whereArgs: [phone],
    );
    if (maps.isNotEmpty) {
      return Contact.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int?> getCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db!.rawQuery("SELECT COUNT(*) FROM contact"),
    );
  }

  Future<int?> delete(int id) async {
    final db = await database;
    await db?.delete(
      'contact',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int?> update(int id, Contact contact) async {
    final db = await database;
    await db?.update(
      'contact',
      contact.toJson(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db!.close();
  }
}

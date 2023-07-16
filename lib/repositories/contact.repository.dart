import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class ContactRepository {
  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, "contacts.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute("""
         CREATE TABLE contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          phone TEXT,
          image TEXT
          )
          """);
    });
  }

  Future<int> save(Contact contact) async {
    final db = await init();

    return db.insert(
      "contacts",
      contact.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Contact>> getAll() async {
    final db = await init();
    final maps = await db.query("contacts");

    return List.generate(maps.length, (i) {
      //create a list of memos
      return Contact.fromJson(maps[i]);
    });
  }

  Future<Contact?> getById(int id) async {
    final db = await init();
    final maps = await db.query(
      "contacts",
      where: "id = ?",
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int?> getCount() async {
    final db = await init();
    var count = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM contact"),
    );

    return count;
  }

  Future<int> updateMemo(int id, Contact contact) async {
    final db = await init();

    int result = await db
        .update("contacts", contact.toJson(), where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future<int> deleteMemo(int id) async {
    final db = await init();

    int result = await db.delete("contacts", //table name
        where: "id = ?",
        whereArgs: [id]);

    return result;
  }
}

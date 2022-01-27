import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as sysPath;

class DBHelper {
  static Future<sql.Database> db() async {
    final dir = await sql.getDatabasesPath();
    return sql.openDatabase(sysPath.join(dir, 'NotesDataBase.db'),
        onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE notes(id TEXT PRIMARY KEY, title TEXT, content TEXT, date TEXT, color INT, image TEXT)',
      );
    }, version: 1);
  }

  static Future<void> insertToDB(
      String table, Map<String, dynamic> data) async {
    final sqlDB = await db();
    await sqlDB.insert(table, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getDataBase(String table) async {
    final sqlDB = await db();
    return sqlDB.query(table);
  }

  static Future<dynamic> updateDB(
      String table, Map<String, dynamic> data, String noteId) async {
    final db = await DBHelper.db();
    return db.update('notes', data, where: 'id= ? ', whereArgs: [noteId]);
  }

  static Future<int> deleteFromDB(String id) async {
    final db = await DBHelper.db();
    return db.delete('notes', where: 'id=?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> searchDB(String search) async {
    final db = await DBHelper.db();
    return db.rawQuery(
        "select * from notes where title like '%$search%' or content like '%$search%'");
  }
}

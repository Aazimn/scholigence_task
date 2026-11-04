import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';

class DbService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'categories.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE categories (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            name      TEXT NOT NULL,
            parent_id INTEGER
          )
        ''');
      },
    );
  }


  static Future<int> addCategory(String name, {int? parentId}) async {
    final db = await database;
    return db.insert('categories', {'name': name, 'parent_id': parentId});
  }


  static Future<List<Category>> getChildrenPaged(int? parentId, int page, int pageSize) async {
    final db = await database;
    final offset = (page - 1) * pageSize;
    final rows = parentId == null
        ? await db.query('categories', where: 'parent_id IS NULL', orderBy: 'name ASC', limit: pageSize, offset: offset)
        : await db.query('categories', where: 'parent_id = ?', whereArgs: [parentId], orderBy: 'name ASC', limit: pageSize, offset: offset);
    return rows.map(Category.fromMap).toList();
  }


  static Future<int> getChildrenCount(int? parentId) async {
    final db = await database;
    final whereClause = parentId == null ? 'parent_id IS NULL' : 'parent_id = ?';
    final whereArgs = parentId == null ? null : [parentId];
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM categories WHERE $whereClause', whereArgs ?? []));
    return count ?? 0;
  }
  
  static Future<List<Category>> getChildren(int? parentId) async {
    final db = await database;
    final rows = parentId == null
        ? await db.query('categories', where: 'parent_id IS NULL', orderBy: 'name ASC')
        : await db.query('categories', where: 'parent_id = ?', whereArgs: [parentId], orderBy: 'name ASC');
    return rows.map(Category.fromMap).toList();
  }



  static Future<bool> hasChildren(int id) async {
    final db = await database;
    final result = await db.query('categories', where: 'parent_id = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty;
  }


  static Future<void> deleteCategory(int id) async {
    final db = await database;
    final children = await getChildren(id);
    for (final child in children) {
      await deleteCategory(child.id!);
    }
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Category>> searchCategoriesPaged(String query, int page, int pageSize) async {
    final db = await database;
    final offset = (page - 1) * pageSize;
    final rows = await db.query(
      'categories',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
      limit: pageSize,
      offset: offset,
    );
    return rows.map(Category.fromMap).toList();
  }

  static Future<int> getSearchCount(String query) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM categories WHERE name LIKE ?', ['%$query%']);
    final count = Sqflite.firstIntValue(result);
    return count ?? 0;
  }

  static Future<List<Category>> searchCategories(String query) async {
    final db = await database;
    final rows = await db.query(
      'categories',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return rows.map(Category.fromMap).toList();
  }


  static Future<List<Category>> getCategoryPath(int id) async {
    final db = await database;
    final path = <Category>[];
    int? currentId = id;

    while (currentId != null) {
      final rows = await db.query('categories', where: 'id = ?', whereArgs: [currentId]);
      if (rows.isEmpty) break;
      final cat = Category.fromMap(rows.first);
      path.insert(0, cat); 
      currentId = cat.parentId;
    }

    return path;
  }
}

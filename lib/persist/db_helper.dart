import 'package:retail_bill/persist/bill.dart';
import 'package:path/path.dart';
import 'package:retail_bill/persist/settings.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "billing.db";
  static final _databaseVersion = 1;
 
  static final table = 'bill';
  static final tableSettings = 'settings';

  static final columnId = 'id';
  static final columnBillNumber = 'billNumber';
  static final columnDatetime = 'dateTime';
  static final columnQuantity = 'quantity';
  static final columnAmount = 'amount';
  static final columnItems = 'items';
  static final columnDiscount = 'discount';

  static final columnConnectedBtDevice = 'connectedBtDevice';
  static final columnBillCounter = 'billCounter';
  static final columnBillCounterDate = 'billCounterDate';
  static final columnLastBackupDate = 'lastBackupDate';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
 
  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }
 
  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }
 
  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnBillNumber INTEGER NOT NULL,
            $columnDatetime INTEGER NOT NULL,
            $columnQuantity REAL NOT NULL,
            $columnAmount REAL NOT NULL,
            $columnDiscount REAL,
            $columnItems TEXT NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableSettings (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnBillCounter INTEGER NOT NULL,
            $columnBillCounterDate INTEGER NOT NULL,
            $columnConnectedBtDevice TEXT NOT NULL,
            $columnLastBackupDate INTEGER NOT NULL
          )
          ''');
  }
 
  // Helper methods
 
  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Bill bill) async {
    Database db = await instance.database;
    return await db.insert(table, bill.toMap());
  }
 
  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(startDate, endDate) async {
    Database db = await instance.database;
    // return await db.query(table, orderBy: "$columnDatetime DESC");
    return await db.query(table, where: "$columnDatetime >= $startDate and $columnDatetime < $endDate", orderBy: "$columnDatetime DESC");
  }
   
  // Queries rows based on the argument received
  Future<List<Map<String, dynamic>>> queryRows(number) async {
    Database db = await instance.database;
    return await db.query(table, where: "$columnBillNumber LIKE '%$number%'");
  }
 
  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'))!;
  }
 
  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Bill bill) async {
    Database db = await instance.database;
    int id = bill.toMap()['id'];
    return await db.update(table, bill.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }
 
  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> insertSettings(Settings settings) async {
    Database db = await instance.database;
    return await db.insert(tableSettings, settings.toMap());
  }

  // Queries rows based on the argument received
  Future<List<Settings>> querySettings() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> list = await db.query(tableSettings, where: "$columnId LIKE '%1%'");
    List<Settings> settings = List.empty(growable: true);
    for (var map in list) {
        settings.add(Settings.fromMap(map));
    }
    return settings;
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> updateSettings(Settings settings) async {
    Database db = await instance.database;
    Map<String, dynamic> data = settings.toMap();
    return await db.update(tableSettings, data, where: '$columnId = ?', whereArgs: [1]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> deleteSettings(int id) async {
    Database db = await instance.database;
    return await db.delete(tableSettings, where: '$columnId = ?', whereArgs: [id]);
  }
}
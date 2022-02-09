import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final _dbName = 'myDb.db'; // Database
  static final _dbVersion = 9; // Database version
  static final _tableName = 'Records'; // Table of Records
  static final _tblUser = 'User'; // Table of User
  static final _tblFarmerRec = 'FarmerRec'; // Table of Farmers of the Users

  // Columns of table smsLogs
  static final colID = 'id';
  static final colRecID = 'RecID';
  static final colnewID = 'NewID';
  static final colRecDate = 'RecDate';
  static final colDateCancelled = 'DateCancelled';
  static final colFarmerNo = 'FarmerNo';
  static final colFarmerName = 'Name';
  static final colPickupPoint = 'PickupPoint';
  static final colWrapper = 'Wrapper';
  static final colNonWrapper = 'NonWrapper';
  static final colRemarks = 'Remarks';
  static final colSentFrom = 'SentFrom';
  static final colCreatedBy = 'CreatedBy';
  static final colBatchedDate = 'BatchedDate';

  // Columns of table User
  static final colUserID = 'UserID';
  static final colAPIkey = 'APIKey';
  static final colName = 'Name';
  static final colPosition = 'Position';

  // Column of table FarmerRec
  static final colUFarmerNo = 'FarmerNo';
  static final colUName = 'Name';

  DbHelper._();
  static final DbHelper db = DbHelper._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;
    else

      // if _database is null we instantiate it
      _database = await _initDb();
    return _database;
  }

  _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE $_tableName ("
          "$colID INTEGER PRIMARY KEY,"
          "$colRecID INTEGER NOT NULL,"
          "$colRecDate DATETIME NOT NULL,"
          "$colDateCancelled DATETIME,"
          "$colBatchedDate DATETIME,"
          "$colFarmerNo TEXT NOT NULL,"
          "$colFarmerName TEXT,"
          "$colPickupPoint TEXT NOT NULL,"
          "$colWrapper INTEGER,"
          "$colNonWrapper INTEGER,"
          "$colRemarks TEXT,"
          "$colSentFrom TEXT NOT NULL,"
          "$colCreatedBy TEXT NOT NULL"
          ")");
      await db.execute("CREATE TABLE $_tblUser ("
          "$colID INTEGER PRIMARY KEY,"
          "$colUserID TEXT NOT NULL,"
          "$colAPIkey TEXT NOT NULL,"
          "$colName INTEGER NOT NULL,"
          "$colPosition INTEGER NOT NULL"
          ")");
      await db.execute('''
      CREATE TABLE $_tblFarmerRec (
        $colID INTEGER PRIMARY KEY,
        $colUFarmerNo TEXT,
        $colUName TEXT
      )
      ''');
    }, onUpgrade: (db, int oldversion, int newversion) async {
      if (oldversion < newversion) {
        await db.execute('''
      ALTER TABLE $_tableName ADD $colBatchedDate DATETIME
      ''');
        await db.execute('''
      ALTER TABLE $_tableName ADD $colCreatedBy TEXT
      ''');
      }
    });
  }

  // ------- Table Functions for VISA Records Queries ---------

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(_tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(
      String filter, String position) async {
    Database db = await database;
    if (position == "LFA")
      return await db.query(_tableName,
          where: "$colSentFrom = ? AND $colFarmerNo LIKE ?",
          whereArgs: ['$filter', '%NAB%'],
          orderBy: '$colID ASC');
    else if (position == "FS")
      return await db.query(_tableName,
          where: "$colSentFrom = ? AND $colFarmerNo NOT LIKE ?",
          whereArgs: ['$filter', '%NAB%'],
          orderBy: '$colID ASC');
    else
      return await db.query(_tableName,
          where: "$colSentFrom = ?",
          whereArgs: ['$filter'],
          orderBy: '$colID ASC');
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row[colRecID];
    return await db
        .update(_tableName, row, where: '$colRecID = ?', whereArgs: [id]);
  }

  Future<List> checkRec(int recID) async {
    Database db = await database;
    return await db
        .query(_tableName, where: "$colRecID = ?", whereArgs: [recID]);
  }

  Future<List> getFarmerNo(int recID) async {
    Database db = await database;
    return await db
        .query(_tableName, where: "$colRecID = ?", whereArgs: [recID]);
  }

  Future<void> deleteRecord() async {
    Database db = await database;
    return await db.delete(_tableName);
  }

  // -------- Table Functions for User Queries ---------

  // Insert the Users
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(_tblUser, row);
  }

  // Get the users API Key
  Future<List<Map<String, dynamic>>> getClient() async {
    final db = await database;
    return await db.query(_tblUser, limit: 1, orderBy: "$colID DESC");
  }

  // ---------- Table Functions for Farmer Names Queries ----------

  // Insertion of Farmers
  Future<int> insertFarmers(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(_tblFarmerRec, row);
  }

  // Get Farmers
  Future<List> getFarmers(String name) async {
    Database db = await database;
    return await db.query(_tblFarmerRec,
        where: "$colUName LIKE ?", whereArgs: ['%$name%'], limit: 4);
  }

  // Check Farmers
  Future<List> checkFarmers(String farmerNo) async {
    Database db = await database;
    return await db.query(_tblFarmerRec,
        where: "$colUFarmerNo LIKE ?", whereArgs: ['%$farmerNo%']);
  }
}

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import '../map_page.dart';

class LocationDatabaseHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute('''CREATE TABLE location (
                    id INTEGER PRIMARY KEY,
                    latitude REAL,
                    longitude REAL,
                    time TEXT
                    )''');
  }

  static Future<sql.Database> db() {
    return sql.openDatabase('locationList.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<int?> insertLocation(LocationData locationData) async {
    final db = await LocationDatabaseHelper.db();
    // final existingLocation = await getLocationWithSameCoordinates(locationData);

    final data = {
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
      'time': locationData.time,
    };
    final result = await db.query('location',
        where: 'latitude = ? AND longitude = ?',
        whereArgs: [locationData.latitude, locationData.longitude]);
    final id = await db.insert('location', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getlocation() async {
    final db = await LocationDatabaseHelper.db();
    return db.query('location', orderBy: "id");
  }

  static Future<void> deleteCity(int id) async {
    final db = await LocationDatabaseHelper.db();
    try {
      await db.delete("location", where: "id=?", whereArgs: [id]);
    } catch (err) {}
  }
}

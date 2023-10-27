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
    final existingLocation = await getLocationWithSameCoordinates(locationData);

    if (existingLocation == null) {
      final data = {
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'time': locationData.time,
      };

      final id = await db.insert('location', data,
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
      return id;
    } else {
      // Display a dialog to inform the user that the location is already recorded
      // You can replace this with your dialog implementation
      showDialogToUser(existingLocation['time']);
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getlocation() async {
    final db = await LocationDatabaseHelper.db();
    return db.query('location', orderBy: "id");
  }

  static Future<Map<String, dynamic>?> getLocationWithSameCoordinates(
      LocationData locationData) async {
    final db = await LocationDatabaseHelper.db();
    final result = await db.query('location',
        where: 'latitude = ? AND longitude = ?',
        whereArgs: [locationData.latitude, locationData.longitude]);

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  static void showDialogToUser(String existingLocationTime) {
    print("ALready connected");
  }
}

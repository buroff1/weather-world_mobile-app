import 'package:sqflite/sqflite.dart'; // Import the sqflite package for database operations
import 'package:path/path.dart'; // Import the path package for working with file paths

// Database helper class to manage SQLite database operations
class DatabaseHelper {
  // Singleton instance of DatabaseHelper
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Private variable to hold the database instance
  static Database? _database;

  // Factory constructor to return the singleton instance
  factory DatabaseHelper() {
    return _instance;
  }

  // Private internal constructor
  DatabaseHelper._internal();

  // Getter to access the database instance
  Future<Database> get database async {
    // Return the existing database instance if it exists
    if (_database != null) return _database!;
    // Otherwise, initialize the database
    _database = await _initDatabase();
    return _database!;
  }

  // Method to initialize the database
  Future<Database> _initDatabase() async {
    // Get the path to the database file
    String path = join(await getDatabasesPath(), 'favorite_cities.db');
    // Open the database and create the 'favorites' table if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favorites(id INTEGER PRIMARY KEY, city TEXT)',
        );
      },
    );
  }

  // Method to insert a city into the 'favorites' table
  Future<void> insertCity(String city) async {
    // Get the database instance
    final db = await database;
    // Insert the city into the 'favorites' table
    await db.insert(
      'favorites',
      {'city': city},
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Replace if the city already exists
    );
  }

  // Method to retrieve the list of favorite cities
  Future<List<String>> getFavoriteCities() async {
    // Get the database instance
    final db = await database;
    // Query the 'favorites' table and get the results
    final List<Map<String, dynamic>> maps = await db.query('favorites');

    // Convert the query results to a list of city names
    return List.generate(maps.length, (i) {
      return maps[i]['city'];
    });
  }

  // Method to delete a city from the 'favorites' table
  Future<void> deleteCity(String city) async {
    // Get the database instance
    final db = await database;
    // Delete the city from the 'favorites' table where the city matches the given city
    await db.delete(
      'favorites',
      where: 'city = ?',
      whereArgs: [city],
    );
  }
}

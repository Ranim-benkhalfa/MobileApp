import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

// Classe pour gérer la base de données SQLite
class DatabaseHelper {
  // Singleton : une seule instance pour toute l'app
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database; // instance de la base

  // Accéder à la base de données
  Future<Database> get database async {
    _database ??= await _initDatabase(); // créer si n'existe pas
    return _database!;
  }

  // Créer ou ouvrir la base de données
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'contacts.db'); // chemin du fichier
    print('📂 Database path: $path');

    return await openDatabase(
      path,
      version: 3,               // version de la DB
      onCreate: _createDatabase, // si DB n'existe pas
      onUpgrade: _onUpgrade,     // si version change
    );
  }

  // Créer les tables
  Future<void> _createDatabase(Database db, int version) async {
    // Table pour les contacts
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT
      )
    ''');

    // Table pour les utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }

  // Mise à jour de la DB si version change
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // ici on peut ajouter de nouvelles colonnes ou tables
  }

  // ────────────────
  // Contacts CRUD
  // ────────────────

  // Ajouter un contact
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace); // remplace si id existe
  }

  // Lire tous les contacts
  Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('contacts', orderBy: 'name ASC'); // tri par nom
    return maps.map((map) => Contact.fromMap(map)).toList(); // convertir en Contact
  }

  // Mettre à jour un contact
  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update('contacts', contact.toMap(),
        where: 'id = ?', whereArgs: [contact.id]); // update où id match
  }

  // Supprimer un contact
  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  // ────────────────
  // Utilisateur Auth
  // ────────────────

  // Ajouter un utilisateur
  Future<int> insertUser(String name, String email, String password) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    }, conflictAlgorithm: ConflictAlgorithm.abort); // échoue si email existe
  }

  // Vérifier login
  Future<bool> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return result.isNotEmpty; // true si utilisateur trouvé
  }
}

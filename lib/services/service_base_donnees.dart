import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modeles/modele_media.dart';
import '../modeles/modele_etiquette.dart';
import '../modeles/modele_parametres.dart';

class ServiceBaseDeDonnees {
  static Database? _baseDeDonnees;

  Future<Database> get baseDeDonnees async {
    if (_baseDeDonnees != null) return _baseDeDonnees!;
    _baseDeDonnees = await _initialiserBaseDeDonnees();
    return _baseDeDonnees!;
  }

  Future<Database> _initialiserBaseDeDonnees() async {
    String chemin = join(await getDatabasesPath(), 'silicapture.db');
    return await openDatabase(
      chemin,
      version: 1,
      onCreate: _creerTables,
    );
  }

  Future<void> _creerTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        cheminLocal TEXT NOT NULL,
        etiquettes TEXT,
        dateCreation TEXT NOT NULL,
        annotations TEXT,
        dossier TEXT,
        estFavori INTEGER,
        miniature TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE etiquettes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT UNIQUE NOT NULL,
        couleur TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE parametres(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        themeSombre INTEGER,
        qualiteImage INTEGER,
        sauvegardeAuto INTEGER,
        notifications INTEGER,
        langue TEXT
      )
    ''');

    // Insérer les paramètres par défaut
    await db.insert('parametres', ParametresUtilisateur().versMap());
  }

  // CRUD pour ElementMedia
  Future<int> insererMedia(ElementMedia media) async {
    Database db = await baseDeDonnees;
    return await db.insert('medias', media.versMap());
  }

  Future<List<ElementMedia>> obtenirTousMedias() async {
    Database db = await baseDeDonnees;
    List<Map<String, dynamic>> maps = await db.query('medias', orderBy: 'dateCreation DESC');
    return maps.map((map) => ElementMedia.depuisMap(map)).toList();
  }

  Future<int> supprimerMedia(int id) async {
    Database db = await baseDeDonnees;
    return await db.delete('medias', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD pour Etiquette
  Future<int> insererEtiquette(Etiquette etiquette) async {
    Database db = await baseDeDonnees;
    return await db.insert('etiquettes', etiquette.versMap());
  }

  // CRUD pour ParametresUtilisateur
  Future<int> mettreAJourParametres(ParametresUtilisateur parametres) async {
    Database db = await baseDeDonnees;
    return await db.update('parametres', parametres.versMap(), where: 'id = 1');
  }

  Future<ParametresUtilisateur> obtenirParametres() async {
    Database db = await baseDeDonnees;
    List<Map<String, dynamic>> maps = await db.query('parametres', where: 'id = 1');
    if (maps.isEmpty) {
      return ParametresUtilisateur();
    }
    return ParametresUtilisateur.depuisMap(maps.first);
  }
}
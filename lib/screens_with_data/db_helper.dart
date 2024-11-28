import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  String matchTable = 'match';
  String matchScoreTable = 'matchScore';
  String matchResultTable = 'matchResult';
  String matchChoiceTable = 'matchChoice';
  String choiceTable = 'choice';
  String scoreTable = 'score';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper!;
  }

  Future<Database?> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'wrestling.db');
    var wrestlingDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return wrestlingDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $matchTable('
        'MatchID INTEGER PRIMARY KEY AUTOINCREMENT, '
        'RedOpp TEXT, '
        'GreenOpp TEXT, '
        'RedSchool TEXT, '
        'GreenSchool TEXT, '
        'WeightClass INTEGER'
        ')');

    await db.execute('CREATE TABLE $matchScoreTable('
        'MatchScoreID INTEGER PRIMARY KEY AUTOINCREMENT, '
        'MatchID INTEGER, '
        'Time TEXT, '
        'Period INTEGER, '
        'ScoreID INTEGER, '
        'Scorer TEXT, '
        'FOREIGN KEY (MatchID) REFERENCES $matchTable(MatchID), '
        'FOREIGN KEY (ScoreID) REFERENCES $scoreTable(ScoreID)'
        ')');

    await db.execute('CREATE TABLE $matchResultTable('
        'MatchResultID INTEGER PRIMARY KEY AUTOINCREMENT, '
        'MatchID INTEGER, '
        'Result TEXT, '
        'Time TEXT, '
        'RedOppScore INTEGER, '
        'GreenOppScore INTEGER, '
        'Period INTEGER, '
        'FOREIGN KEY (MatchID) REFERENCES $matchTable(MatchID)'
        ')');

    await db.execute('CREATE TABLE $matchChoiceTable('
        'MatchChoiceID INTEGER PRIMARY KEY AUTOINCREMENT, '
        'MatchID INTEGER, '
        'ChoiceID INTEGER, '
        'Period INTEGER, '
        'FOREIGN KEY (MatchID) REFERENCES $matchTable(MatchID), '
        'FOREIGN KEY (ChoiceID) REFERENCES $choiceTable(ChoiceID)'
        ')');

    await db.execute('CREATE TABLE $choiceTable('
        'ChoiceID INTEGER PRIMARY KEY AUTOINCREMENT, '
        'choice TEXT, '
        'Description TEXT'
        ')');

    await db.execute('CREATE TABLE $scoreTable('
        'ScoreID INTEGER PRIMARY KEY AUTOINCREMENT, '
        'Score TEXT, '
        'Description TEXT, '
        'Points INTEGER'
        ')');

    // Insert default choices and scores
    await db.rawInsert('INSERT INTO $choiceTable (ChoiceID, choice, Description) VALUES (1, "Up", "Up")');
    await db.rawInsert('INSERT INTO $choiceTable (ChoiceID, choice, Description) VALUES (2, "Down", "Down")');
    await db.rawInsert('INSERT INTO $choiceTable (ChoiceID, choice, Description) VALUES (3, "Neutral", "Neutral")');
    await db.rawInsert('INSERT INTO $choiceTable (ChoiceID, choice, Description) VALUES (4, "Defer", "Defer")');
    await db.rawInsert('INSERT INTO $choiceTable (ChoiceID, choice, Description) VALUES (5, "Alternative", "Alternative")');

    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (1, "T3", "Takedown", 3)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (2, "E1", "Escape", 1)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (3, "R2", "Reversal", 2)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (4, "N2", "Near Fall", 2)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (5, "N3", "Near Fall", 3)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (6, "N4", "Near Fall", 4)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (7, "N5", "Near Fall", 5)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (8, "P1", "Penalty", 1)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (9, "P2", "Penalty", 2)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (10, "C0", "Caution", 0)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (11, "S0", "Stalling", 0)');
    await db.rawInsert('INSERT INTO $scoreTable (ScoreID, Score, Description, Points) VALUES (12, "V1", "Technical Violation", 1)');
  }
}

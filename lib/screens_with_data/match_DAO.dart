import 'dart:developer';

import 'package:camera_recording_game/screens_with_data/db_helper.dart';
import 'package:camera_recording_game/screens_with_data/models/combile_model.dart';
import 'package:camera_recording_game/screens_with_data/models/match_Score.dart';
import 'package:camera_recording_game/screens_with_data/models/match_model.dart';
import 'package:sqflite/sqflite.dart';

class MatchDAO {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  // Insert operation
  Future<int> insertMatch(Match match) async {
    Database? db = await databaseHelper.database;
    int result = await db!.insert(databaseHelper.matchTable, match.toMap());
    log("result Insert Match $result");
    return result;
  }

  Future<int> insertMatchScore(MatchScore matchScore) async {
    Database? db = await databaseHelper.database;
    int result = await db!.insert(databaseHelper.matchScoreTable, matchScore.toMap());
    log("Result ${matchScore.toMap()}.");
    // await getMatchScores(1).then((value) {
    //   log("value.length ${value[0].period}");
    // });
    return result;
  }

  Future<int> insertMatchResult(MatchResult matchResult) async {
    Database? db = await databaseHelper.database;
    int result = await db!.insert(databaseHelper.matchResultTable, matchResult.toMap());
    return result;
  }

  Future<int> insertMatchChoice(MatchChoice matchChoice) async {
    Database? db = await databaseHelper.database;
    int result = await db!.insert(databaseHelper.matchChoiceTable, matchChoice.toMap());
    return result;
  }

  // Update operation
  Future<int> updateMatch(Match match) async {
    Database? db = await databaseHelper.database;
    int result = await db!.update(
      databaseHelper.matchTable,
      match.toMap(),
      where: 'MatchID = ?',
      whereArgs: [match.matchID],
    );
    return result;
  }

  Future<int> updateMatchScore(MatchScore matchScore) async {
    Database? db = await databaseHelper.database;
    int result = await db!.update(
      databaseHelper.matchScoreTable,
      matchScore.toMap(),
      where: 'MatchScoreID = ?',
      whereArgs: [matchScore.matchScoreID],
    );
    return result;
  }

  Future<int> updateMatchResult(MatchResult matchResult) async {
    Database? db = await databaseHelper.database;
    int result = await db!.update(
      databaseHelper.matchResultTable,
      matchResult.toMap(),
      where: 'MatchResultID = ?',
      whereArgs: [matchResult.matchResultID],
    );
    return result;
  }

  Future<int> updateMatchChoice(MatchChoice matchChoice) async {
    Database? db = await databaseHelper.database;
    int result = await db!.update(
      databaseHelper.matchChoiceTable,
      matchChoice.toMap(),
      where: 'MatchChoiceID = ?',
      whereArgs: [matchChoice.matchChoiceID],
    );
    return result;
  }

  // Delete operation
  Future<int> deleteMatch(int matchID) async {
    Database? db = await databaseHelper.database;
    int result = await db!.delete(
      databaseHelper.matchTable,
      where: 'MatchID = ?',
      whereArgs: [matchID],
    );
    return result;
  }

  Future<int> deleteMatchScore(int matchScoreID) async {
    Database? db = await databaseHelper.database;
    int result = await db!.delete(
      databaseHelper.matchScoreTable,
      where: 'MatchScoreID = ?',
      whereArgs: [matchScoreID],
    );
    return result;
  }

  Future<int> deleteMatchResult(int matchResultID) async {
    Database? db = await databaseHelper.database;
    int result = await db!.delete(
      databaseHelper.matchResultTable,
      where: 'MatchResultID = ?',
      whereArgs: [matchResultID],
    );
    return result;
  }

  Future<int> deleteMatchChoice(int matchChoiceID) async {
    Database? db = await databaseHelper.database;
    int result = await db!.delete(
      databaseHelper.matchChoiceTable,
      where: 'MatchChoiceID = ?',
      whereArgs: [matchChoiceID],
    );
    return result;
  }

  // Get operation
  Future<List<Match>> getMatches() async {
    Database? db = await databaseHelper.database;
    List<Map<String, dynamic>> maps = await db!.query(databaseHelper.matchTable);
    return List.generate(maps.length, (i) {
      return Match(
        matchID: maps[i]['MatchID'],
        redOpp: maps[i]['RedOpp'],
        greenOpp: maps[i]['GreenOpp'],
        redSchool: maps[i]['RedSchool'],
        greenSchool: maps[i]['GreenSchool'],
        weightClass: maps[i]['WeightClass'],
      );
    });
  }

  Future<List<MatchScore>> getMatchScores(int matchID) async {
    Database? db = await databaseHelper.database;
    List<Map<String, dynamic>> maps = await db!.query(
      databaseHelper.matchScoreTable,
      where: 'MatchID = ?',
      whereArgs: [matchID],
    );
    return List.generate(maps.length, (i) {
      return MatchScore(
        matchScoreID: maps[i]['MatchScoreID'],
        matchID: maps[i]['MatchID'],
        time: maps[i]['Time'],
        period: maps[i]['Period'],
        scoreID: maps[i]['ScoreID'],
        scorer: maps[i]['Scorer'],
      );
    });
  }

  Future<List<MatchResult>> getMatchResults(int matchID) async {
    Database? db = await databaseHelper.database;
    List<Map<String, dynamic>> maps = await db!.query(
      databaseHelper.matchResultTable,
      where: 'MatchID = ?',
      whereArgs: [matchID],
    );
    return List.generate(maps.length, (i) {
      return MatchResult(
        matchResultID: maps[i]['MatchResultID'],
        matchID: maps[i]['MatchID'],
        result: maps[i]['Result'],
        time: maps[i]['Time'],
        redOppScore: maps[i]['RedOppScore'],
        greenOppScore: maps[i]['GreenOppScore'],
        period: maps[i]['Period'],
      );
    });
  }

  Future<List<MatchChoice>> getMatchChoices(int matchID) async {
    Database? db = await databaseHelper.database;
    List<Map<String, dynamic>> maps = await db!.query(
      databaseHelper.matchChoiceTable,
      where: 'MatchID = ?',
      whereArgs: [matchID],
    );
    return List.generate(maps.length, (i) {
      return MatchChoice(
        matchChoiceID: maps[i]['MatchChoiceID'],
        matchID: maps[i]['MatchID'],
        choiceID: maps[i]['ChoiceID'],
        period: maps[i]['Period'],
      );
    });
  }

  // Implement getters for Choice and Score tables similarly

  Future<List<ScoreModel>> getScores() async {
    Database? db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db!.query(databaseHelper.scoreTable);
    return List.generate(maps.length, (i) {
      return ScoreModel(
        scoreID: maps[i]['ScoreID'],
        score: maps[i]['Score'],
        description: maps[i]['Description'],
        points: maps[i]['Points'],
      );
    });
  }
}

import 'dart:developer';

import 'package:camera_recording_game/screens_with_data/match_DAO.dart';
import 'package:camera_recording_game/screens_with_data/models/combile_model.dart';
import 'package:camera_recording_game/screens_with_data/models/match_Score.dart';
import 'package:camera_recording_game/screens_with_data/models/match_model.dart';
import 'package:flutter/material.dart';

class Score {
  int matchScoreID;
  int matchID;
  String time;
  int period;
  int scoreID;
  String scorer;
  DateTime timestamp;
  String description;
  Color color;
  String greenPlayer;
  String redPlayer;

  Score({
    required this.matchScoreID,
    required this.matchID,
    required this.time,
    required this.period,
    required this.scoreID,
    required this.scorer,
    required this.timestamp,
    required this.color,
    required this.description,
    required this.greenPlayer,
    required this.redPlayer,
  });

  Map<String, dynamic> toMap() {
    return {
      'scoreID': scoreID,
      'description': description,
      'scorer': scorer,
      'timestamp': timestamp.toIso8601String(),
      'period': period,
      'color': color.value,
      'time': time,
      'matchID': matchID,
      'matchScoreID': matchScoreID,
      'greenPlayer': greenPlayer,
      'redPlayer': redPlayer,
    };
  }

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      matchID: map['matchID'],
      scoreID: map['scoreID'],
      description: map['description'],
      scorer: map['scorer'],
      timestamp: DateTime.parse(map['timestamp']),
      period: map['period'],
      color: Color(map['color']),
      matchScoreID: map['matchScoreID'],
      time: map['time'],
      greenPlayer: map['greenPlayer'],
      redPlayer: map['redPlayer'],
    );
  }
}

class ScoreProvider extends ChangeNotifier {
  final MatchDAO matchDAO = MatchDAO();

  List<Score> _scores = [];
  int _totalScore1 = 0;
  int _totalScore2 = 0;
  int _nextMatchScoreID = 1;
  int _currentMatchID = 1;
  int currentPeriod = 1;
  Map<String, dynamic> _matchDetails = {};
  bool isEndingLoader = false;
  List<Score> get scores => _scores;

  int get totalScore1 => _totalScore1;
  int get totalScore2 => _totalScore2;

  Map<String, dynamic> get matchDetails => _matchDetails;

  DateTime? _periodStartTime;
  int _periodDurationMinutes = 2;

  void startPeriod() {
    _periodStartTime = DateTime.now();
  }

  void setCurrentPeriod(int period) {
    currentPeriod = period;
    notifyListeners();
  }

  String _getElapsedPeriodTime() {
    if (_periodStartTime == null) return '0:00';
    final elapsed = DateTime.now().difference(_periodStartTime!);
    final minutes = elapsed.inMinutes % _periodDurationMinutes;
    final seconds = elapsed.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  getResultData() async {
    log('match[0].scoreID; }');

    List<MatchScore> match = await matchDAO.getMatchScores(_nextMatchScoreID);
    log('match[0].scoreID; ${match.length}');
  }

  void addScore(
    int score,
    String description,
    String player,
    int period,
    Color color,
    matchScoreID,
    String lapTime,
  ) async {
    final newScore = Score(
      color: color,
      matchScoreID: _nextMatchScoreID,
      matchID: _currentMatchID,
      time: lapTime,
      period: period,
      scoreID: score,
      scorer: player,
      timestamp: DateTime.now(),
      description: description,
      greenPlayer: matchDetails['GreenOpp'],
      redPlayer: matchDetails['RedOpp'],
    );
    _scores.add(newScore);
    if (color == Colors.red) {
      _totalScore1 += score;
    } else if (color == Colors.green) {
      _totalScore2 += score;
    }

    var matchScore = MatchScore(
        matchID: _currentMatchID, time: lapTime, period: period, scoreID: score, scorer: player);
    matchDAO.insertMatchScore(matchScore);
    _nextMatchScoreID++;
    notifyListeners();
  }

  void changePeriod(context) {
    if (currentPeriod < 3) {
      currentPeriod++;
      notifyListeners();
    }
  }

  void updateMatchDetail(String key, String value) {
    if (_matchDetails.containsKey(key)) {
      _matchDetails[key] = value;
      matchDAO.updateMatch(Match.fromMap(_matchDetails));

      notifyListeners();
    }

    log(' matchDAO.getMatches(); ${matchDAO.getMatches()}');
  }

  void setMatchDetails(Map<String, dynamic> details) {
    _matchDetails = details;
    notifyListeners();
  }

  updateIsEndingLoader(bool isLoading) {
    isEndingLoader = isLoading;
    notifyListeners();
  }

  void endMatch(String decision, String time, String reason) {
    updateIsEndingLoader(true);
    var matchResult = MatchResult(
      matchID: _currentMatchID,
      result: decision,
      time: time,
      redOppScore: _totalScore1,
      greenOppScore: _totalScore2,
      period: currentPeriod,
    );

    log('matchResult ${matchResult.toMap()}');
    matchDAO.insertMatchResult(matchResult);
    // Optionally, you can clear scores or reset states
    resetMatchState();
    updateIsEndingLoader(false);

    notifyListeners();
  }

  void resetMatchState() {
    _scores.clear();
    _totalScore1 = 0;
    _totalScore2 = 0;
    _nextMatchScoreID = 1;
    currentPeriod = 1;
    _periodStartTime = null;
    //  _matchDetails.clear();

    notifyListeners();
  }

  // Method to edit a score
  void editScore(int matchScoreID, int newScore, String newDescription, String newPlayer,
      int newPeriod, Color newColor) {
    final index = _scores.indexWhere((score) => score.matchScoreID == matchScoreID);
    if (index != -1) {
      final oldScore = _scores[index];
      if (oldScore.color == Colors.red) {
        _totalScore1 -= oldScore.scoreID;
      } else if (oldScore.color == Colors.green) {
        _totalScore2 -= oldScore.scoreID;
      }

      _scores[index] = Score(
        matchScoreID: matchScoreID,
        matchID: oldScore.matchID,
        time: oldScore.time,
        period: newPeriod,
        scoreID: newScore,
        scorer: newPlayer,
        timestamp: oldScore.timestamp,
        color: newColor,
        description: newDescription,
        greenPlayer: matchDetails['GreenOpp'],
        redPlayer: matchDetails['RedOpp'],
      );

      if (newColor == Colors.red) {
        _totalScore1 += newScore;
      } else if (newColor == Colors.green) {
        _totalScore2 += newScore;
      }

      notifyListeners();
    }
  }

  // Method to delete a score
  void deleteScore(int matchScoreID) {
    final index = _scores.indexWhere((score) => score.matchScoreID == matchScoreID);
    if (index != -1) {
      final oldScore = _scores.removeAt(index);
      if (oldScore.color == Colors.red) {
        _totalScore1 -= oldScore.scoreID;
      } else if (oldScore.color == Colors.green) {
        _totalScore2 -= oldScore.scoreID;
      }
      notifyListeners();
    }
  }
}

class MatchScore {
  int? matchScoreID;
  int matchID;
  String time;
  int period;
  int scoreID;
  String scorer;

  MatchScore({
    this.matchScoreID,
    required this.matchID,
    required this.time,
    required this.period,
    required this.scoreID,
    required this.scorer,
  });

  Map<String, dynamic> toMap() {
    return {
      'MatchScoreID': matchScoreID,
      'MatchID': matchID,
      'Time': time,
      'Period': period,
      'ScoreID': scoreID,
      'Scorer': scorer,
    };
  }

  factory MatchScore.fromMap(Map<String, dynamic> map) {
    return MatchScore(
      matchScoreID: map['MatchScoreID'],
      matchID: map['MatchID'],
      time: map['Time'],
      period: map['Period'],
      scoreID: map['ScoreID'],
      scorer: map['Scorer'],
    );
  }
}


class ScoreModel {
  int? scoreID;
  String score;
  String description;
  int points;

  ScoreModel({
    this.scoreID,
    required this.score,
    required this.description,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'ScoreID': scoreID,
      'Score': score,
      'Description': description,
      'Points': points,
    };
  }

  factory ScoreModel.fromMap(Map<String, dynamic> map) {
    return ScoreModel(
      scoreID: map['ScoreID'],
      score: map['Score'],
      description: map['Description'],
      points: map['Points'],
    );
  }
}


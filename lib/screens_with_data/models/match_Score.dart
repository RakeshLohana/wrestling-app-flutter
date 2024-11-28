class MatchResult {
  int? matchResultID;
  int matchID;
  String result;
  String time;
  int redOppScore;
  int greenOppScore;
  int period;

  MatchResult({
    this.matchResultID,
    required this.matchID,
    required this.result,
    required this.time,
    required this.redOppScore,
    required this.greenOppScore,
    required this.period,
  });

  Map<String, dynamic> toMap() {
    return {
      'MatchResultID': matchResultID,
      'MatchID': matchID,
      'Result': result,
      'Time': time,
      'RedOppScore': redOppScore,
      'GreenOppScore': greenOppScore,
      'Period': period,
    };
  }

  factory MatchResult.fromMap(Map<String, dynamic> map) {
    return MatchResult(
      matchResultID: map['MatchResultID'],
      matchID: map['MatchID'],
      result: map['Result'],
      time: map['Time'],
      redOppScore: map['RedOppScore'],
      greenOppScore: map['GreenOppScore'],
      period: map['Period'],
    );
  }
}
class MatchChoice {
  int? matchChoiceID;
  int matchID;
  int choiceID;
  int period;

  MatchChoice({
    this.matchChoiceID,
    required this.matchID,
    required this.choiceID,
    required this.period,
  });

  Map<String, dynamic> toMap() {
    return {
      'MatchChoiceID': matchChoiceID,
      'MatchID': matchID,
      'ChoiceID': choiceID,
      'Period': period,
    };
  }

  factory MatchChoice.fromMap(Map<String, dynamic> map) {
    return MatchChoice(
      matchChoiceID: map['MatchChoiceID'],
      matchID: map['MatchID'],
      choiceID: map['ChoiceID'],
      period: map['Period'],
    );
  }
}


class Choice {
  int? choiceID;
  String choice;
  String description;

  Choice({
    this.choiceID,
    required this.choice,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'ChoiceID': choiceID,
      'Choice': choice,
      'Description': description,
    };
  }

  factory Choice.fromMap(Map<String, dynamic> map) {
    return Choice(
      choiceID: map['ChoiceID'],
      choice: map['Choice'],
      description: map['Description'],
    );
  }
}

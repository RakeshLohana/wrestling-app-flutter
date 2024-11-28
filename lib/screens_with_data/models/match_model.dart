class Match {
  int? matchID;
  String redOpp;
  String greenOpp;
  String redSchool;
  String greenSchool;
  int weightClass;

  Match({
    this.matchID,
    required this.redOpp,
    required this.greenOpp,
    required this.redSchool,
    required this.greenSchool,
    required this.weightClass,
  });

  Map<String, dynamic> toMap() {
    return {
      'MatchID': matchID,
      'RedOpp': redOpp,
      'GreenOpp': greenOpp,
      'RedSchool': redSchool,
      'GreenSchool': greenSchool,
      'WeightClass': weightClass,
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      matchID: map['MatchID'],
      redOpp: map['RedOpp'],
      greenOpp: map['GreenOpp'],
      redSchool: map['RedSchool'],
      greenSchool: map['GreenSchool'],
      weightClass: map['WeightClass'],
    );
  }
}

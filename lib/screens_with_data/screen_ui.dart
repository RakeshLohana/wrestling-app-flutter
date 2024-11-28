import 'dart:developer';

import 'package:camera_recording_game/screens_with_data/resonsive_helper.dart';
import 'package:camera_recording_game/screens_with_data/result.dart';
import 'package:camera_recording_game/screens_with_data/screen_ui_Score.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'score_provider.dart';
import '/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'match_DAO.dart';
import 'recording_screen/HeaderCameraScoreWidget.dart';
import 'recording_screen/score_dislplay.dart';
import 'stopWathch/stopwatch_provider.dart';

class HomeScreen extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onStopRecording;
  final bool isOpaque;
  final Function onScoreTap;

  const HomeScreen({
    super.key,
    required this.isRecording,
    required this.onStopRecording,
    required this.isOpaque,
    required this.onScoreTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<List<Map<String, dynamic>>> redButtons = [
    [
      {'score': 1, 'description': 'P1', 'color': Colors.red},
      {'score': 2, 'description': 'P2', 'color': Colors.red},
      {'score': 0, 'description': 'C0', 'color': Colors.red},
      {'score': 1, 'description': 'V1', 'color': Colors.red},
    ],
    [
      {'score': 3, 'description': 'N3', 'color': Colors.red},
      {'score': 4, 'description': 'N4', 'color': Colors.red},
      {'score': 5, 'description': 'N5', 'color': Colors.red},
      {'score': 0, 'description': 'S0', 'color': Colors.red},
    ],
    [
      {'score': 3, 'description': 'T3', 'color': Colors.red},
      {'score': 1, 'description': 'E1', 'color': Colors.red},
      {'score': 2, 'description': 'R2', 'color': Colors.red},
      {'score': 2, 'description': 'N2', 'color': Colors.red},
    ],
  ];

  final List<List<Map<String, dynamic>>> greenButtons = [
    [
      {'score': 3, 'description': 'T3', 'color': Colors.green},
      {'score': 1, 'description': 'E1', 'color': Colors.green},
      {'score': 2, 'description': 'R2', 'color': Colors.green},
      {'score': 2, 'description': 'N2', 'color': Colors.green},
    ],
    [
      {'score': 1, 'description': 'P1', 'color': Colors.green},
      {'score': 2, 'description': 'P2', 'color': Colors.green},
      {'score': 0, 'description': 'C0', 'color': Colors.green},
      {'score': 1, 'description': 'V1', 'color': Colors.green},
    ],
    [
      {'score': 3, 'description': 'N3', 'color': Colors.green},
      {'score': 4, 'description': 'N4', 'color': Colors.green},
      {'score': 5, 'description': 'N5', 'color': Colors.green},
      {'score': 0, 'description': 'S0', 'color': Colors.green},
    ],
  ];
  final List<List<Map<String, dynamic>>> buttonLabels = [
    [
      {'score': 1, 'description': 'P1', 'color': Colors.red},
      {'score': 2, 'description': 'P2', 'color': Colors.red},
      {'score': 0, 'description': 'C0', 'color': Colors.red},
      {'score': 1, 'description': 'V1', 'color': Colors.red},
      {'score': 3, 'description': 'N3', 'color': Colors.red},
      {'score': 4, 'description': 'N4', 'color': Colors.red},
      {'score': 5, 'description': 'N5', 'color': Colors.red},
      {'score': 0, 'description': 'S0', 'color': Colors.red},
    ],
    [
      {'score': 3, 'description': 'T3', 'color': Colors.red},
      {'score': 1, 'description': 'E1', 'color': Colors.red},
      {'score': 3, 'description': 'T3', 'color': Colors.green},
      {'score': 1, 'description': 'E1', 'color': Colors.green},
      {'score': 2, 'description': 'R2', 'color': Colors.red},
      {'score': 2, 'description': 'N2', 'color': Colors.red},
      {'score': 2, 'description': 'R2', 'color': Colors.green},
      {'score': 2, 'description': 'N2', 'color': Colors.green},
    ],
    [
      {'score': 1, 'description': 'P1', 'color': Colors.green},
      {'score': 2, 'description': 'P2', 'color': Colors.green},
      {'score': 0, 'description': 'C0', 'color': Colors.green},
      {'score': 1, 'description': 'V1', 'color': Colors.green},
      {'score': 3, 'description': 'N3', 'color': Colors.green},
      {'score': 4, 'description': 'N4', 'color': Colors.green},
      {'score': 5, 'description': 'N5', 'color': Colors.green},
      {'score': 0, 'description': 'S0', 'color': Colors.green},
    ],
    //['Button 9', 'Button 10', 'Button 11', 'Button 12', 'Button 13', 'Button 14', 'Button 15', 'Button 16'],
    // ['T3', 'E1', 'R2', 'N2', 'N3', 'N4', 'N5', 'P1'],
    // ['Button 17', 'Button 18', 'Button 19', 'Button 20', 'Button 21', 'Button 22', 'Button 23', 'Button 24'],
  ];
  final PageController _pageController = PageController(initialPage: 1);

  final MatchDAO matchDAO = MatchDAO();
  void _showOptionsDialog(BuildContext context, Score score) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Text('Do you want to edit or delete this score?'),
          actions: <Widget>[
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
                _showEditDialog(context, score);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(context, score);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Score score) {
    final TextEditingController scoreController =
        TextEditingController(text: score.scoreID.toString());
    final TextEditingController descriptionController =
        TextEditingController(text: score.description);
    final TextEditingController playerController =
        TextEditingController(text: score.scorer);
    final TextEditingController periodController =
        TextEditingController(text: score.period.toString());
    Color selectedColor = score.color;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Score'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: scoreController,
                  decoration: InputDecoration(labelText: 'Score'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: playerController,
                  decoration: InputDecoration(labelText: 'Player'),
                ),
                TextField(
                  controller: periodController,
                  decoration: InputDecoration(labelText: 'Period'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButton<Color>(
                  value: selectedColor,
                  onChanged: (Color? newValue) {
                    selectedColor = newValue!;
                  },
                  items: <Color>[Colors.red, Colors.green]
                      .map<DropdownMenuItem<Color>>((Color value) {
                    return DropdownMenuItem<Color>(
                      value: value,
                      child: Text(value == Colors.red ? 'Red' : 'Green'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'),
              onPressed: () {
                int newScore = int.parse(scoreController.text);
                String newDescription = descriptionController.text;
                String newPlayer = playerController.text;
                int newPeriod = int.parse(periodController.text);

                context.read<ScoreProvider>().editScore(
                      score.matchScoreID,
                      newScore,
                      newDescription,
                      newPlayer,
                      newPeriod,
                      selectedColor,
                    );

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Score score) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this score?'),
          actions: <Widget>[
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                context.read<ScoreProvider>().deleteScore(score.matchScoreID);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showScoreEditDialog(BuildContext context, String team) {
    TextEditingController _scoreController = TextEditingController();
    // Pre-fill the score controller if you have the current score available
    // _scoreController.text = currentScore.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Score for $team'),
          content: TextField(
            controller: _scoreController,
            decoration: InputDecoration(labelText: 'New Score'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int newScore = int.parse(_scoreController.text);
                // Update the score for the team
                if (team == 'red') {
                  // Update red team score
                } else if (team == 'green') {
                  // Update green team score
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: SizedBox(
        child: Column(
          children: [
            // Consumer<ScoreProvider>(
            //   builder: (context, scoreProvider, child) {
            //     return Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Container(
            //           alignment: Alignment.center,
            //           height: getResponsiveHeight(context, 50),
            //           width: getResponsiveHeight(context, 50),
            //           color: Colors.grey.shade800.withOpacity(0.6), // 60% transparency
            //           child: DropdownButtonHideUnderline(
            //             // Hide the underline
            //             child: DropdownButton<int>(
            //               value: scoreProvider.currentPeriod,
            //               dropdownColor: Colors.grey.shade400.withOpacity(0.6), // 60% transparency
            //               style: TextStyle(
            //                   color: Colors.white, fontSize: getResponsiveFontSize(context, 20)),
            //               onChanged: (int? newValue) {
            //                 if (newValue != null) {
            //                   scoreProvider.setCurrentPeriod(newValue);
            //                 }
            //               },
            //               iconSize: 2,
            //               items: List.generate(8, (index) => index + 1)
            //                   .map<DropdownMenuItem<int>>((int value) {
            //                 return DropdownMenuItem<int>(
            //                   value: value,
            //                   child: Center(
            //                     child: Text(
            //                       value.toString(),
            //                       style: TextStyle(
            //                           color: Colors.white,
            //                           fontSize: getResponsiveFontSize(context, 16)),
            //                     ),
            //                   ),
            //                 );
            //               }).toList(),
            //             ),
            //           ),
            //         ),
            //         Column(
            //           children: [
            //             // Conditional rendering based on total scores
            //             scoreProvider.totalScore1 >= scoreProvider.totalScore2
            //                 ? _buildScoreRow(
            //                     context,
            //                     'RedOpp', // Key for matchDetails
            //                     Colors.red,
            //                     scoreProvider.totalScore1,
            //                     scoreProvider.scores
            //                         .where((e) => e.color == Colors.red)
            //                         .map((e) => e.description.trim())
            //                         .join(' '),
            //                     scoreProvider,
            //                   )
            //                 : _buildScoreRow(
            //                     context,
            //                     'GreenOpp', // Key for matchDetails
            //                     Colors.green.shade800,
            //                     scoreProvider.totalScore2,
            //                     scoreProvider.scores
            //                         .where((e) => e.color == Colors.green)
            //                         .map((e) => e.description.trim())
            //                         .join(' '),
            //                     scoreProvider,
            //                   ),

            //             scoreProvider.totalScore1 >= scoreProvider.totalScore2
            //                 ? _buildScoreRow(
            //                     context,
            //                     'GreenOpp', // Key for matchDetails
            //                     Colors.green.shade800,
            //                     scoreProvider.totalScore2,
            //                     scoreProvider.scores
            //                         .where((e) => e.color == Colors.green)
            //                         .map((e) => e.description.trim())
            //                         .join(' '),
            //                     scoreProvider,
            //                   )
            //                 : _buildScoreRow(
            //                     context,
            //                     'RedOpp', // Key for matchDetails
            //                     Colors.red,
            //                     scoreProvider.totalScore1,
            //                     scoreProvider.scores
            //                         .where((e) => e.color == Colors.red)
            //                         .map((e) => e.description.trim())
            //                         .join(' '),
            //                     scoreProvider,
            //                   ),
            //           ],
            //         )
            //       ],
            //     );
            //   },
            // ),
            Opacity(
                opacity: widget.isOpaque ? 1 : 0, child: ScoreDisplayScreen()),

            isPortrait
                ? Align(
                    alignment: const Alignment(0, 0),
                    child: SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: buttonLabels.length,
                        itemBuilder: (context, pageIndex) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 1,
                            ),
                            itemCount: buttonLabels[pageIndex].length,
                            itemBuilder: (context, buttonIndex) {
                              var data = buttonLabels[pageIndex][buttonIndex];
                              log('data[color]  ${data['color']} ${context.read<ScoreProvider>().matchDetails['RedOpp']}}');
                              return ScoreButton(
                                isRecording: widget.isRecording,
                                period:
                                    context.read<ScoreProvider>().currentPeriod,
                                score: data['score'],
                                description: data['description'],
                                color: data['color'],
                                player: data['color'] == Colors.red
                                    ? context
                                        .read<ScoreProvider>()
                                        .matchDetails['RedOpp']
                                    : context
                                        .read<ScoreProvider>()
                                        .matchDetails['GreenOpp'],
                                isOpaque: widget.isOpaque,
                                onScoreTap: widget.onScoreTap,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: PageView.builder(
                            // controller: PageController(),
                            itemCount: redButtons.length,
                            itemBuilder: (context, pageIndex) {
                              return GridView.builder(
                                padding: const EdgeInsets.all(16.0),
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 10.0,
                                  childAspectRatio: 1,
                                ),
                                itemCount: redButtons[pageIndex].length,
                                itemBuilder: (context, buttonIndex) {
                                  var data = redButtons[pageIndex][buttonIndex];
                                  log('data[color]  ${data['color']} ${context.read<ScoreProvider>().matchDetails['RedOpp']}}');
                                  return ScoreButton(
                                    isRecording: widget.isRecording,
                                    period: context
                                        .read<ScoreProvider>()
                                        .currentPeriod,
                                    score: data['score'],
                                    description: data['description'],
                                    color: data['color'],
                                    player: data['color'] == Colors.red
                                        ? context
                                            .read<ScoreProvider>()
                                            .matchDetails['RedOpp']
                                        : context
                                            .read<ScoreProvider>()
                                            .matchDetails['GreenOpp'],
                                    isOpaque: widget.isOpaque,
                                    onScoreTap: widget.onScoreTap,
                                  );
                                },
                              );
                            }),
                      ),
                      Container(
                        width: 200,
                        height: 200,
                        // color: Colors.green,
                        child: PageView.builder(
                            // controller: PageController(),
                            itemCount: greenButtons.length,
                            itemBuilder: (context, pageIndex) {
                              return GridView.builder(
                                padding: const EdgeInsets.all(16.0),
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 10.0,
                                  childAspectRatio: 1,
                                ),
                                itemCount: greenButtons[pageIndex].length,
                                itemBuilder: (context, buttonIndex) {
                                  var data =
                                      greenButtons[pageIndex][buttonIndex];
                                  log('data[color]  ${data['color']} ${context.read<ScoreProvider>().matchDetails['RedOpp']}}');
                                  return ScoreButton(
                                    isRecording: widget.isRecording,
                                    period: context
                                        .read<ScoreProvider>()
                                        .currentPeriod,
                                    score: data['score'],
                                    description: data['description'],
                                    color: data['color'],
                                    player: data['color'] == Colors.red
                                        ? context
                                            .read<ScoreProvider>()
                                            .matchDetails['RedOpp']
                                        : context
                                            .read<ScoreProvider>()
                                            .matchDetails['GreenOpp'],
                                    isOpaque: widget.isOpaque,
                                    onScoreTap: widget.onScoreTap,
                                  );
                                },
                              );
                            }),
                      )
                    ],
                  ),
            // Align(
            //     alignment: const Alignment(0, 0),
            //     child: SizedBox(
            //       height: 150,
            //       child: PageView.builder(
            //         controller: _pageController,
            //         itemCount: buttonLabels.length,
            //         itemBuilder: (context, pageIndex) {
            //           return GridView.builder(
            //             padding: const EdgeInsets.all(16.0),
            //             physics: NeverScrollableScrollPhysics(),
            //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //               crossAxisCount: 4,
            //               crossAxisSpacing: 20,
            //               mainAxisSpacing: 10.0,
            //               childAspectRatio: 2,
            //             ),
            //             itemCount: buttonLabels[pageIndex].length,
            //             itemBuilder: (context, buttonIndex) {
            //               var data = buttonLabels[pageIndex][buttonIndex];
            //               log('data[color]  ${data['color']} ${context.read<ScoreProvider>().matchDetails['RedOpp']}}');
            //               return Container(
            //                 margin: EdgeInsets.only(
            //                   right: (buttonIndex % 2 == 1) ? 40.0 : 0.0,
            //                 ),
            //                 child: RotatedBox(
            //                   quarterTurns: isPortrait ? 0 : 1,
            //                   child: ScoreButton(
            //                     isRecording: widget.isRecording,
            //                     period: context.read<ScoreProvider>().currentPeriod,
            //                     score: data['score'],
            //                     description: data['description'],
            //                     color: data['color'],
            //                     player: data['color'] == Colors.red
            //                         ? context.read<ScoreProvider>().matchDetails['RedOpp']
            //                         : context.read<ScoreProvider>().matchDetails['GreenOpp'],
            //                     isOpaque: widget.isOpaque,
            //                     onScoreTap: widget.onScoreTap,
            //                     rotateText: -1.57,
            //                   ),
            //                 ),
            //               );
            //             },
            //           );
            //         },
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(
      BuildContext context,
      String opponentKey,
      Color backgroundColor,
      int totalScore,
      String scoreDescriptions,
      ScoreProvider scoreProvider) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                String newName = scoreProvider.matchDetails[opponentKey];
                return AlertDialog(
                  title: Text('Update Opponent Name'),
                  content: TextField(
                    decoration: InputDecoration(hintText: newName),
                    onChanged: (value) {
                      newName = value;
                      scoreProvider.updateMatchDetail(opponentKey, value);
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        // scoreProvider.matchDetails
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            height: getResponsiveHeight(context, 25),
            width: getResponsiveWidth(context, 100),
            color: backgroundColor,
            alignment: Alignment.centerLeft,
            child: Text(
              '${scoreProvider.matchDetails[opponentKey]}',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: getResponsiveFontSize(context, 14)),
            ),
          ),
        ),
        PositionLabel(
          backgroundColor: Colors.green,
          onPositionChange: (newPosition) {
            // Handle position change
          },
        ),
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ScoreDisplayScreen()));
            // Navigator.push(context, MaterialPageRoute(builder: (_) => ScoreListPage()));
          },
          child: Container(
            alignment: Alignment.centerLeft,
            height: getResponsiveHeight(context, 25),
            width: getResponsiveWidth(context, 150),
            color: backgroundColor.withOpacity(0.8),
            child: Text(
              scoreDescriptions,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getResponsiveFontSize(
                    context, 12), // Adjust the font size as needed
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (widget.isRecording) {
              widget.onStopRecording();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ResultScreen(),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ResultScreen(),
                ),
              );
            }
            context.read<StopwatchProvider>().resetStopwatch();
          },
          child: Container(
            alignment: Alignment.center,
            height: getResponsiveHeight(context, 25),
            width: getResponsiveWidth(context, 25),
            color: backgroundColor.withOpacity(0.9),
            child: Text(
              '$totalScore',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: getResponsiveFontSize(context, 14)),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

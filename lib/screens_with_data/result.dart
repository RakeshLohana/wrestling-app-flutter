import 'dart:developer';

import 'package:camera_recording_game/screens_with_data/stopWathch/stopwatch_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'score_provider.dart';

import 'score_provider.dart';
import 'video_player_page.dart';

class ResultScreen extends StatelessWidget {
  final String? videoPath;

  const ResultScreen({super.key,  this.videoPath});
  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to exit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Close the dialog and return true
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    ).then((exit) {
      if (exit == true) {
        // Exit the app
        exit(0);
      }
    });
  }

  void _showEndMatchDialog(BuildContext context) {
    String? selectedDecision;
    String reason = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('End Match'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: const Text('Select Decision'),
                    value: selectedDecision,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDecision = newValue;
                      });
                    },
                    items: <String>[
                      'Regular Decision',
                      'Major Decision',
                      'Pin',
                      'Technical Fall',
                      'Disqualification'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  // TextField(
                  //   decoration: InputDecoration(labelText: 'Time'),
                  //   onChanged: (value) {
                  //     time = value;
                  //   },
                  // ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Reason'),
                    onChanged: (value) {
                      reason = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Exit'),
                  onPressed: () {
                    // Navigator.of(context).pop();
                    _showExitConfirmationDialog(context);
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    log('selectedDecision${selectedDecision}');
                    if (selectedDecision != null) {
                      Provider.of<ScoreProvider>(context, listen: false).endMatch(
                        selectedDecision!,
                        context
                            .read<StopwatchProvider>()
                            .formatDuration(context.read<StopwatchProvider>().elapsedTime),
                        reason,
                      );
                      context.read<StopwatchProvider>().resetStopwatch();

                      Navigator.of(context).pop();
                    } else {
                      // Show error message or handle invalid input
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Result'),
      ),
      body: SingleChildScrollView(
        child: Consumer<ScoreProvider>(
          builder: (context, scoreProvider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Player 1 Total Score: ${scoreProvider.totalScore1}',
                  style: const TextStyle(color: Colors.red, fontSize: 24),
                ),
                Text(
                  'Player 2 Total Score: ${scoreProvider.totalScore2}',
                  style: const TextStyle(color: Colors.green, fontSize: 24),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('MatchScoreID')),
                      DataColumn(label: Text('MatchID')),
                      DataColumn(label: Text('Time')),
                      DataColumn(label: Text('Period')),
                      DataColumn(label: Text('ScoreID')),
                      DataColumn(label: Text('Scorer')),
                    ],
                    rows: scoreProvider.scores.map((score) {
                      return DataRow(cells: [
                        DataCell(Text(score.matchScoreID.toString())),
                        DataCell(Text(score.matchID.toString())),
                        DataCell(Text(score.time)),
                        DataCell(Text(score.period.toString())),
                        DataCell(Text(score.scoreID.toString())),
                        DataCell(Text(score.scorer)),
                      ]);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () async {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (context) => VideoPlayerPage(filePath: videoPath),
                //       ),
                //     );

                //     await scoreProvider.getResultData();
                //   },
                //   child: const Text('Play Video'),
                // ),
                // ElevatedButton(
                //   onPressed: () => _showEndMatchDialog(context),
                //   child: const Text('End Match'),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}

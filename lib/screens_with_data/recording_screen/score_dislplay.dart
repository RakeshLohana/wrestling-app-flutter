import 'package:camera_recording_game/screens_with_data/resonsive_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../score_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScoreDisplayScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollGreenController = ScrollController();
  // void _showDeleteConfirmationDialog(BuildContext context, Score score) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Delete Confirmation'),
  //         content: Text('Are you sure you want to delete this score?'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Delete'),
  //             onPressed: () {
  //               context.read<ScoreProvider>().deleteScore(score.matchScoreID);
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showDeleteConfirmationDialog(BuildContext context, Score score) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to delete the below score?'),
              const SizedBox(height: 8.0),
              Text('Period: ${score.period}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Name: ${score.scorer}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  'Color: ${score.color.value.toString() == "4283215696" ? "Green" : "Red"}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('ScoreLine: ${score.description}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                context.read<ScoreProvider>().deleteScore(score.matchScoreID);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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

    return isPortrait
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.center,
                  color: Colors.red.withOpacity(0.3),
                  width: 50,
                  child: Consumer<ScoreProvider>(
                    builder: (context, scoreProvider, child) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollController
                            .jumpTo(_scrollController.position.maxScrollExtent);
                      });
                      return ListView(
                        controller: _scrollController,
                        shrinkWrap: true,
                        reverse: true,
                        children: _buildPeriodScores(
                            context, scoreProvider, Colors.red),
                      );
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.green.withOpacity(0.3),
                  width: 50,
                  child: Consumer<ScoreProvider>(
                    builder: (context, scoreProvider, child) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollGreenController.jumpTo(
                            _scrollGreenController.position.maxScrollExtent);
                      });
                      return ListView(
                        controller: _scrollGreenController,
                        reverse: true,
                        shrinkWrap: true,
                        children: _buildPeriodScores(
                            context, scoreProvider, Colors.green),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 130,
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.red.withOpacity(0.3),
                  width: 50,
                  child: Consumer<ScoreProvider>(
                    builder: (context, scoreProvider, child) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollController
                            .jumpTo(_scrollController.position.maxScrollExtent);
                      });
                      return ListView(
                        controller: _scrollController,
                        shrinkWrap: true,
                        reverse: true,
                        children: _buildPeriodScores(
                            context, scoreProvider, Colors.red),
                      );
                    },
                  ),
                ),
                const Spacer(),
                Container(
                  alignment: Alignment.center,
                  color: Colors.green.withOpacity(0.3),
                  width: 50,
                  child: Consumer<ScoreProvider>(
                    builder: (context, scoreProvider, child) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollGreenController.jumpTo(
                            _scrollGreenController.position.maxScrollExtent);
                      });
                      return ListView(
                        shrinkWrap: true,
                        controller: _scrollGreenController,
                        reverse: true,
                        children: _buildPeriodScores(
                            context, scoreProvider, Colors.green),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 120,
                ),
              ],
            ),
          );
  }

  List<Widget> _buildPeriodScores(
      BuildContext context, ScoreProvider scoreProvider, Color color) {
    // Group scores by period
    final periodMap = <int, List<Score>>{};
    for (var score in scoreProvider.scores.where((s) => s.color == color)) {
      periodMap.putIfAbsent(score.period, () => []).add(score);
    }

    // Create a list of widgets, one for each period and its scores
    final periodWidgets = <Widget>[];
    periodMap.forEach((period, scores) {
      periodWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'P$period',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...scores.reversed
                .map(
                  (score) => GestureDetector(
                    onTap: () {
                      _showDeleteConfirmationDialog(context, score);
                      // scoreProvider.deleteScore(score.matchScoreID);
                    },
                    child: Container(
                      // color: color.withOpacity(0.7),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        score.description,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      );
    });

    return periodWidgets.reversed.toList();
  }
}


//update
import 'package:camera_recording_game/screens_with_data/score_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScoreListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score List'),
      ),
      body: Consumer<ScoreProvider>(
        builder: (context, scoreProvider, child) {
          return ListView.builder(
            itemCount: scoreProvider.scores.length,
            itemBuilder: (context, index) {
              final score = scoreProvider.scores[index];
              return ScoreWidget(score: score, backgroundColor: score.color);
            },
          );
        },
      ),
    );
  }
}

class ScoreWidget extends StatelessWidget {
  final Score score;
  final Color backgroundColor;

  ScoreWidget({required this.score, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showOptionsDialog(context, score);
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.symmetric(vertical: 4.0),
        color: backgroundColor.withOpacity(0.8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score: ${score.scoreID}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Time: ${score.time}'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${score.scorer}'),
                Text('Period: ${score.period}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
    final TextEditingController playerController = TextEditingController(text: score.scorer);
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
                  items:
                      <Color>[Colors.red, Colors.green].map<DropdownMenuItem<Color>>((Color value) {
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
}

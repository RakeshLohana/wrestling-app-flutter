import 'dart:io';

import 'package:camera_recording_game/screens_with_data/models/match_model.dart';
import 'package:camera_recording_game/screens_with_data/match_DAO.dart';
import 'package:camera_recording_game/screens_with_data/stopWathch/match_list_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../main.dart';
// import 'recording_screen/recording_screen.dart';
import 'score_provider.dart';

class MatchInputScreen extends StatefulWidget {
  @override
  _MatchInputScreenState createState() => _MatchInputScreenState();
}

class _MatchInputScreenState extends State<MatchInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _redOppController = TextEditingController();
  final _greenOppController = TextEditingController();
  final _redSchoolController = TextEditingController();
  final _greenSchoolController = TextEditingController();
  final _weightClassController = TextEditingController();
  final MatchDAO matchDAO = MatchDAO();
  @override
  void dispose() {
    _redOppController.dispose();
    _greenOppController.dispose();
    _redSchoolController.dispose();
    _greenSchoolController.dispose();
    _weightClassController.dispose();
    super.dispose();
  }

  

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Exit'),
          content: Text('Are you sure you want to exit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Close the dialog and return true
              },
              child: Text('Exit'),
            ),
          ],
        );
      },
    ).then((exit) {
      if (exit == true) {
        SystemNavigator.pop();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    });
  }

  void clearAllField() {
    _redOppController.clear();
    _greenOppController.clear();
    _redSchoolController.clear();
    _greenSchoolController.clear();
    _weightClassController.clear();

    _formKey.currentState?.reset();
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final matchDetails = {
        'RedOpp': _redOppController.text,
        'GreenOpp': _greenOppController.text,
        'RedSchool': _redSchoolController.text,
        'GreenSchool': _greenSchoolController.text,
        'WeightClass': int.parse(_weightClassController.text),
      };

      Match match = Match.fromMap(matchDetails);
      Provider.of<ScoreProvider>(context, listen: false).setMatchDetails(matchDetails);
      matchDAO.insertMatch(match);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RecordScreen(camera: firstCamera)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Match Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _redOppController,
                decoration: InputDecoration(labelText: 'Red Opponent'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the red opponent';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _greenOppController,
                decoration: InputDecoration(labelText: 'Green Opponent'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the green opponent';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _redSchoolController,
                decoration: InputDecoration(labelText: 'Red School'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the red school';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _greenSchoolController,
                decoration: InputDecoration(labelText: 'Green School'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the green school';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightClassController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Weight Class'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the weight class';
                  }
                  return null;
                },
              ),
              SizedBox(height: 26),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: Text('Submit'),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => clearAllField(),
                child: Text('Reset'),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => _showExitConfirmationDialog(context),
                child: Text('Exit'),
              ),
              SizedBox(
                height: 200,
                child: MatchListScreen(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

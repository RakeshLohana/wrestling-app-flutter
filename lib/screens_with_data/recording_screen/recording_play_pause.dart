import 'dart:async';
import 'dart:convert';

import 'package:camera_recording_game/screens_with_data/match_DAO.dart';
import 'package:camera_recording_game/screens_with_data/match_input_Screen.dart';
import 'package:camera_recording_game/screens_with_data/models/combile_model.dart';
import 'package:camera_recording_game/screens_with_data/resonsive_helper.dart';
import 'package:camera_recording_game/screens_with_data/score_provider.dart';
import 'package:camera_recording_game/screens_with_data/stopWathch/match_list_screen.dart';
import 'package:camera_recording_game/screens_with_data/stopWathch/stopwatch_provider.dart';
import 'package:camera_recording_game/screens_with_data/video_player_page.dart';
import 'package:camera_recording_game/main.dart';
import 'package:gal/gal.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:provider/provider.dart';

import '../screen_ui.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer';
import 'dart:io';

class RecordingControls extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final String videoPath;
  final VoidCallback startRecording;
  final VoidCallback pauseRecording;
  final VoidCallback resumeRecording;
  final VoidCallback stopRecording;
  final VoidCallback showEndMatchDialog;
  final VoidCallback changePeriod;
  final double iconSize;

  const RecordingControls({
    required this.isRecording,
    required this.isPaused,
    required this.videoPath,
    required this.startRecording,
    required this.pauseRecording,
    required this.resumeRecording,
    required this.stopRecording,
    required this.showEndMatchDialog,
    this.iconSize = 50.0, required this.changePeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(color: Colors.white, width: 2),
                ),
                backgroundColor: Colors.black26, // Lighter shade
                onPressed: () {
                changePeriod();

                  
                },
                child: Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: isRecording
                      ? (isPaused
                          ? Colors.transparent
                          : Colors.red.withOpacity(0.6))
                      : Colors.black26, // Lighter shade

                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  onPressed: () {
                    if (isRecording) {
                      if (isPaused) {
                        resumeRecording();
                      } else {
                        pauseRecording();
                      }
                    } else {
                      startRecording();
                    }
                  },
                  icon: isRecording
                      ? (isPaused
                          ? Icon(Icons.stop, color: Colors.red, size: 30)
                          : Icon(Icons.circle, color: Colors.white, size: 30))
                      : Icon(Icons.circle, color: Colors.white, size: 30),
                  // Icon(
                  //     isRecording
                  //         ? (isPaused ? Icons.play_arrow : Icons.pause)
                  //         : Icons.circle,
                  //     color: Colors.white, // Icon color white
                  //     size: 30,
                  //   ),
                ),
              ),
              const SizedBox(width: 20),
              FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(color: Colors.white, width: 2),
                ),
                backgroundColor: Colors.black26, // Lighter shade
                onPressed: () {
                  if (isRecording) {
                    stopRecording();
                  }
                  showEndMatchDialog();
                },
                child:
                    Center(child: DiamondIcon(size: 30, color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Center(
        //   child: Consumer<StopwatchProvider>(
        //     builder: (context, stopwatchProvider, child) {
        //       return Text(
        //         stopwatchProvider.formatDuration(stopwatchProvider.elapsedTime),
        //         style: TextStyle(
        //           fontSize: getResponsiveFontSize(context, 15),
        //           color: Colors.white.withOpacity(0.4),
        //           decorationStyle: TextDecorationStyle.dotted,
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

class DiamondIconPainter extends CustomPainter {
  final Color color;

  DiamondIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class DiamondIcon extends StatelessWidget {
  final double size;
  final Color color;

  DiamondIcon({this.size = 40, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: DiamondIconPainter(color),
    );
  }
}

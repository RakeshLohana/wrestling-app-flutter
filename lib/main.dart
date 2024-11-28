import 'dart:async';
import 'dart:convert';

import 'package:camera_recording_game/screens_with_data/authentication/login.dart';
import 'package:camera_recording_game/screens_with_data/match_DAO.dart';
import 'package:camera_recording_game/screens_with_data/match_input_Screen.dart';
import 'package:camera_recording_game/screens_with_data/models/combile_model.dart';
import 'package:camera_recording_game/screens_with_data/providers/auth_provider.dart';
import 'package:camera_recording_game/screens_with_data/recording_screen/score_dislplay.dart';
import 'package:camera_recording_game/screens_with_data/resonsive_helper.dart';
import 'package:camera_recording_game/screens_with_data/stopWathch/match_list_screen.dart';
import 'package:camera_recording_game/screens_with_data/stopWathch/stopwatch_provider.dart';
import 'package:camera_recording_game/utils.dart';
import 'package:gal/gal.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:provider/provider.dart';

import 'screens_with_data/screen_ui.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer';
import 'dart:io';

import 'screens_with_data/recording_screen/HeaderCameraScoreWidget.dart';
import 'screens_with_data/recording_screen/recording_play_pause.dart';
import 'screens_with_data/score_provider.dart';
import 'screens_with_data/video_player_page.dart';

final MatchDAO matchDAO = MatchDAO();

var firstCamera;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScoreProvider(),),
        ChangeNotifierProvider(create: (_) => StopwatchProvider(),),
        ChangeNotifierProvider(create: (_) => AuthProvider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Record and Score App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: //Scaffold(body: BoxingTimerWidget())
            LoginScreen(),
      ),
    );
  }
}

class RecordScreen extends StatefulWidget {
  final CameraDescription camera;

  const RecordScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isRecording = false;
  String videoPath = '';
  bool isPaused = false;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _startOpacityTimer();
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void changePeriod(BuildContext context) {
    if (isRecording && videoPath.isNotEmpty) {
      stopRecording(context: context, isVideoPlayBackScreen: true);
      isRecording = false;
    } else if (!isRecording) {
      isRecording = false;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerPage(filePath: videoPath),
        ),
      );
    }
    context.read<StopwatchProvider>().resetStopwatch();
  }

  Future<void> startRecording(BuildContext context) async {
    try {
      await _initializeControllerFuture;
      final filePathName = DateTime.now().millisecondsSinceEpoch;
      // Get external storage directory
      // final directory = await getExternalStorageDirectory();
      final directory = await getStorageDirectory();
      // if (directory != null) {
      final filePath = join(directory, '$filePathName}.mp4');
      log('filePath $filePath');

      // Start video recording
      await _controller.startVideoRecording();

      // Start stopwatch
      context.read<StopwatchProvider>().startStopwatch();

      /////

      setState(() {
        isRecording = true;
        videoPath = filePath;
        isPaused = false;
        log('videoPath $videoPath');
      });
      // } else {
      //   throw Exception('External storage directory not found');
      // }
    } catch (e) {
      setState(() {
        isRecording = false;
        isPaused = false;
      });
      log('startRecording $e');
    }
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
              title: Text('End Match'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: Text('Select Decision'),
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
                  TextField(
                    decoration: InputDecoration(labelText: 'Reason'),
                    onChanged: (value) {
                      reason = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (selectedDecision != null) {
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (_) => MatchInputScreen()), (route) => false);
                      Provider.of<ScoreProvider>(context, listen: false).endMatch(
                        selectedDecision!,
                        context
                            .read<StopwatchProvider>()
                            .formatDuration(context.read<StopwatchProvider>().elapsedTime),
                        reason,
                      );

                      context.read<StopwatchProvider>().resetStopwatch();
                    } else {
                      // Show error message or handle invalid input
                    }
                  },
                ),
                TextButton(
                  child: Text('Exit'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the End Match dialog
                    _showExitConfirmationDialog(context); // Show the confirmation dialog
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Exit'),
          content: Text('Are you sure you want to exit without saving?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
                if (videoPath.isNotEmpty) {
                  deleteVideoFile(videoPath);
                }
                Provider.of<ScoreProvider>(context, listen: false).resetMatchState();
                context.read<StopwatchProvider>().resetStopwatch();

                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => MatchInputScreen()), (route) => false);
              },
              child: Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteVideoFile(String videoPath) async {
    try {
      final file = File(videoPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted video file: $videoPath');
      }
    } catch (e) {
      debugPrint('Error deleting video file: $e');
    }
  }

  Future<void> stopRecording({required BuildContext context, bool? isVideoPlayBackScreen}) async {
    try {
      final XFile videoFile = await _controller.stopVideoRecording();
      context.read<StopwatchProvider>().stopStopwatch();

      final tempVideoPath = videoFile.path;
      // final directory = await getExternalStorageDirectory();
      final directory = await getStorageDirectory();

      final uniqueID = DateTime.now().millisecondsSinceEpoch.toString();
      final videoDir = Directory('${directory}/MatchVideos/$uniqueID');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      final videoPath = '${videoDir.path}/$uniqueID.mp4';
      final File tempFile = File(tempVideoPath);
      await tempFile.copy(videoPath);

      // Save score data
      final scoreProvider = context.read<ScoreProvider>();
      final scoreData = scoreProvider.scores.map((score) => score.toMap()).toList();
      final redPlayerName = scoreProvider.matchDetails['RedOpp']; // Add this in your provider
      final greenPlayerName = scoreProvider.matchDetails['GreenOpp']; // Add this in your provider
      final timestamp = DateTime.now();
      final matchData = {
        'scores': scoreData,
        'redPlayerName': redPlayerName ?? '',
        'greenPlayerName': greenPlayerName ?? '',
      };
      final scoreFilePath = '${videoDir.path}/$uniqueID.json';
      final scoreFile = File(scoreFilePath);
      await scoreFile.writeAsString(jsonEncode(matchData));

      setState(() {
        this.videoPath = videoPath;
        isRecording = false;

        isPaused = false;
      });

      // Save video to gallery
      final bool? isSaved = await GallerySaver.saveVideo(videoPath);
      log('Video saved to gallery: $isSaved');
      if (isVideoPlayBackScreen ?? false) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(filePath: videoPath),
          ),
        );
      }
    } catch (e, stackTrace) {
      setState(() {
        isRecording = false;

        isPaused = false;
      });
      log('Error stopping recording: $e');
      log('Stack trace: $stackTrace');
    }
  }

  Future<void> pauseRecording(BuildContext context) async {
    try {
      await _controller.pauseVideoRecording();
      context.read<StopwatchProvider>().stopStopwatch();
      setState(() {
        isPaused = true;
      });
    } catch (e) {
      setState(() {
        isPaused = false;
      });
      log('Error pausing recording: $e');
    }
  }

  Future<void> resumeRecording(BuildContext context) async {
    try {
      await _controller.resumeVideoRecording();
      context.read<StopwatchProvider>().startStopwatch();
      setState(() {
        isPaused = false;
      });
    } catch (e) {
      setState(() {
        isPaused = true;
      });
      log('Error resuming recording: $e');
    }
  }

  void replayVideo() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.seekTo(Duration.zero);
      _videoPlayerController!.play();
    }
  }

  bool isOpaque = true;
  Timer? _timer;

  void _startOpacityTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 3), () {
      setState(() {
        isOpaque = false;
      });
    });
  }

  void _handleHeaderTap() {
    setState(() {
      isOpaque = true;
    });

    log('DAATA ');
  }

  @override
  Widget build(BuildContext context) {
    final matchDetails = Provider.of<ScoreProvider>(context).matchDetails;
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                    child: AspectRatio(
                        aspectRatio: 1 / _controller.value.aspectRatio,
                        child: CameraPreview(_controller))),
                HomeScreen(
                  isRecording: isRecording,
                  onStopRecording: () {
                    stopRecording(context: context);
                  },
                  isOpaque: isOpaque,
                  onScoreTap: () {
                    setState(() {
                      isOpaque = true;
                    });
                    _startOpacityTimer();
                  },
                ),
                HeaderCameraScoreWidget(
                  isOpaque: isOpaque,
                  onScoreTap: () {
                    setState(() {
                      isOpaque = true;
                    });
                    _startOpacityTimer();
                  },
                  onHeaderTap: _handleHeaderTap,
                ),
                isPortrait
                    ? Positioned(
                        bottom: 200,
                        left: 0,
                        right: 0,
                        child: RecordingControls(
                          isRecording: isRecording,
                          isPaused: isPaused,
                          videoPath: videoPath,
                          startRecording: () => startRecording(context),
                          pauseRecording: () => pauseRecording(context),
                          resumeRecording: () => resumeRecording(context),
                          stopRecording: () => stopRecording(context: context),
                          showEndMatchDialog: () => _showEndMatchDialog(context),
                          changePeriod: () => changePeriod(context),
                        ),
                      )
                    : Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: RecordingControls(
                          isRecording: isRecording,
                          isPaused: isPaused,
                          videoPath: videoPath,
                          startRecording: () => startRecording(context),
                          pauseRecording: () => pauseRecording(context),
                          resumeRecording: () => resumeRecording(context),
                          stopRecording: () => stopRecording(context: context),
                          showEndMatchDialog: () => _showEndMatchDialog(context),
                          changePeriod: () => changePeriod(context),
                        ),
                      ),
                // // Play And Pause Button
                // MediaQuery.of(context).orientation.index == 0
                //     ? Positioned(
                //         top: MediaQuery.of(context).size.height * 0.55,
                //         left: MediaQuery.of(context).size.width * 0.22,
                //         // right: 0,
                //         child: Column(
                //           // mainAxisAlignment: MainAxisAlignment.center,
                //           // crossAxisAlignment: CrossAxisAlignment.center,
                //           children: [
                //             Center(
                //               child: Row(
                //                 mainAxisSize: MainAxisSize.min,
                //                 // mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   FloatingActionButton(
                //                     shape: CircleBorder(),
                //                     backgroundColor: Colors.grey.shade700,
                //                     onPressed: () {
                //                       if (videoPath.isNotEmpty) {
                //                         Navigator.of(context).push(
                //                           MaterialPageRoute(
                //                             builder: (context) =>
                //                                 VideoPlayerPage(filePath: videoPath),
                //                           ),
                //                         );
                //                       }
                //                     },
                //                     child: const Center(
                //                       child: Icon(
                //                         Icons.play_arrow,
                //                         size: 50,
                //                       ),
                //                     ),
                //                   ),
                //                   const SizedBox(width: 20),
                //                   Container(
                //                     height: 80,
                //                     width: 80,
                //                     decoration: BoxDecoration(
                //                         color: Colors.grey.shade700,
                //                         shape: BoxShape.circle,
                //                         border: Border.all(color: Colors.white, width: 2)),
                //                     child: IconButton(
                //                       onPressed: () {
                //                         if (isRecording) {
                //                           if (isPaused) {
                //                             resumeRecording(context);
                //                           } else {
                //                             pauseRecording(context);
                //                           }
                //                         } else {
                //                           startRecording(context);
                //                         }
                //                       },
                //                       icon: Icon(isRecording
                //                           ? (isPaused ? Icons.play_arrow : Icons.pause)
                //                           : Icons.circle),
                //                     ),
                //                   ),
                //                   const SizedBox(width: 20),
                //                   FloatingActionButton(
                //                     shape: CircleBorder(),
                //                     backgroundColor: Colors.grey.shade700,
                //                     onPressed: () {
                //                       //  changePeriod(context);
                //                       if (isRecording) {
                //                         stopRecording(context);
                //                       }
                //                       _showEndMatchDialog(context);
                //                     },
                //                     child: const Center(
                //                       child: Icon(
                //                         Icons.check,
                //                         size: 45,
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //             SizedBox(height: 10),
                //             Center(
                //               child: Consumer<StopwatchProvider>(
                //                 builder: (context, stopwatchProvider, child) {
                //                   return Text(
                //                     stopwatchProvider.formatDuration(stopwatchProvider.elapsedTime),
                //                     style: TextStyle(
                //                         fontSize: getResponsiveFontSize(context, 15),
                //                         color: Colors.white.withOpacity(0.4),
                //                         // backgroundColor: Colors.redAccent,
                //                         decorationStyle: TextDecorationStyle.dotted),
                //                   );
                //                 },
                //               ),
                //             ),
                //           ],
                //         ),
                //       )
                //     : Positioned(
                //         left: 0,
                //         right: 0,
                //         bottom: 0,
                //         child: Column(
                //           // mainAxisAlignment: MainAxisAlignment.center,
                //           // crossAxisAlignment: CrossAxisAlignment.center,
                //           children: [
                //             Center(
                //               child: Row(
                //                 mainAxisSize: MainAxisSize.min,
                //                 // mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   FloatingActionButton(
                //                     shape: CircleBorder(),
                //                     backgroundColor: Colors.grey.shade700,
                //                     onPressed: () {
                //                       if (videoPath.isNotEmpty) {
                //                         Navigator.of(context).push(
                //                           MaterialPageRoute(
                //                             builder: (context) =>
                //                                 VideoPlayerPage(filePath: videoPath),
                //                           ),
                //                         );
                //                       }
                //                     },
                //                     child: const Center(
                //                       child: Icon(
                //                         Icons.play_arrow,
                //                         size: 50,
                //                       ),
                //                     ),
                //                   ),
                //                   const SizedBox(width: 20),
                //                   Container(
                //                     height: 80,
                //                     width: 80,
                //                     decoration: BoxDecoration(
                //                         color: Colors.grey.shade700,
                //                         shape: BoxShape.circle,
                //                         border: Border.all(color: Colors.white, width: 2)),
                //                     child: IconButton(
                //                       onPressed: () {
                //                         if (isRecording) {
                //                           if (isPaused) {
                //                             resumeRecording(context);
                //                           } else {
                //                             pauseRecording(context);
                //                           }
                //                         } else {
                //                           startRecording(context);
                //                         }
                //                       },
                //                       icon: Icon(isRecording
                //                           ? (isPaused ? Icons.play_arrow : Icons.pause)
                //                           : Icons.circle),
                //                     ),
                //                   ),
                //                   const SizedBox(width: 20),
                //                   FloatingActionButton(
                //                     shape: CircleBorder(),
                //                     backgroundColor: Colors.grey.shade700,
                //                     onPressed: () {
                //                       //  changePeriod(context);
                //                       if (isRecording) {
                //                         stopRecording(context);
                //                       }
                //                       _showEndMatchDialog(context);
                //                     },
                //                     child: const Center(
                //                       child: Icon(
                //                         Icons.check,
                //                         size: 45,
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //             SizedBox(height: 10),
                //             Center(
                //               child: Consumer<StopwatchProvider>(
                //                 builder: (context, stopwatchProvider, child) {
                //                   return Text(
                //                     stopwatchProvider.formatDuration(stopwatchProvider.elapsedTime),
                //                     style: TextStyle(
                //                         fontSize: getResponsiveFontSize(context, 15),
                //                         color: Colors.white.withOpacity(0.4),
                //                         // backgroundColor: Colors.redAccent,
                //                         decorationStyle: TextDecorationStyle.dotted),
                //                   );
                //                 },
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),

                // HomeScreen(
                //   isRecording: isRecording,
                //   onStopRecording: () {
                //     stopRecording(context);
                //   },
                //   isOpaque: isOpaque,
                //   onScoreTap: () {
                //     setState(() {
                //       isOpaque = true;
                //     });
                //     _startOpacityTimer();
                //   },
                // ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class ScoreButton extends StatelessWidget {
  final int score;
  final String description;
  final Color color;
  final String player;
  final int period;
  final bool isRecording;
  final bool isOpaque;
  final Function onScoreTap;
  const ScoreButton({
    Key? key,
    required this.score,
    required this.description,
    required this.color,
    required this.player,
    required this.period,
    required this.isRecording,
    required this.isOpaque,
    required this.onScoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isRecording
          ? () async {
              context.read<StopwatchProvider>().lapStopwatch();
              String lapTime = context.read<StopwatchProvider>().lapTimeStringData;
              List<ScoreModel> scpreModel = await matchDAO.getScores();
              var sc = scpreModel.where((element) => element.score == description);
              onScoreTap();
              log("ONTAP WORJGING ${lapTime}  ${sc.first.scoreID} ${sc.first.points} ONTAP WORJGING ${sc.first.score}");
              Provider.of<ScoreProvider>(context, listen: false)
                  .addScore(score, description, player, period, color, sc.first.scoreID, lapTime);

              context.read<StopwatchProvider>().lapStopwatch();
              log('printing $description');
            }
          : () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.6),
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      child: Text(
        description,
        style: TextStyle(fontSize: 15, color: Colors.white),
        maxLines: 1,
      ),
    );
  }
}

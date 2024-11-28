import 'dart:convert';
import 'dart:developer';
import 'package:camera_recording_game/screens_with_data/match_input_Screen.dart';
import 'package:camera_recording_game/screens_with_data/stopWathch/stopwatch_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'score_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class VideoPlayerPage extends StatefulWidget {
  final String filePath;
  final String? scoreFilePath;

  const VideoPlayerPage({Key? key, required this.filePath, this.scoreFilePath}) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isFullScreen = false;
  List<Score> _scores = [];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _loadScores();
  }

  // Future<void> deleteVideoFile(String videoPath) async {
  //   try {
  //     final file = File(videoPath);
  //     if (await file.exists()) {
  //       await file.delete();
  //       debugPrint('Deleted video file: $videoPath');
  //     }
  //     setState(() {});
  //   } catch (e) {
  //     debugPrint('Error deleting video file: $e');
  //   }
  // }

  Future<void> deleteVideoFile(String videoPath, String? scoreFilePath) async {
    try {
      // Delete the video file
      final videoFile = File(videoPath);
      if (await videoFile.exists()) {
        await videoFile.delete();
        debugPrint('Deleted video file: $videoPath');
      }

      // Delete the JSON file
      if (scoreFilePath != null) {
        final scoreFile = File(scoreFilePath);
        if (await scoreFile.exists()) {
          await scoreFile.delete();
          debugPrint('Deleted score file: $scoreFilePath');
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error deleting files: $e');
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      allowFullScreen: true,
      allowMuting: true,
    );
    setState(() {});
  }

  Future<void> _loadScores() async {
    if (widget.scoreFilePath != null) {
      final scoreFile = File(widget.scoreFilePath!);
      final scoreData = await scoreFile.readAsString();
      final scoreList = jsonDecode(scoreData);

      setState(() {
        _scores = (scoreList['scores'] as List).map((data) => Score.fromMap(data)).toList();
        // _scores =
        //     scoreList['scores'].map((data) => Score.fromMap(data)).toList();
      });
      log("_scores  ${_scores.toList()}");
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
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
                      Provider.of<ScoreProvider>(context, listen: false).endMatch(
                        selectedDecision!,
                        context
                            .read<StopwatchProvider>()
                            .formatDuration(context.read<StopwatchProvider>().elapsedTime),
                        reason,
                      );

                      context.read<StopwatchProvider>().resetStopwatch();
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (_) => MatchInputScreen()), (route) => false);
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
              onPressed: () async {
                if (widget.filePath.isNotEmpty) {
                  await deleteVideoFile(widget.filePath, widget.scoreFilePath);
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

  void _deleteVideo() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final videoFile = File(widget.filePath);
      final scoreFile = File(widget.scoreFilePath!);

      if (await videoFile.exists()) {
        await videoFile.delete();
      }

      if (await scoreFile.exists()) {
        await scoreFile.delete();
      }
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => MatchInputScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              widget.scoreFilePath == null
                  ? Navigator.pop(context)
                  : Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MatchInputScreen()),
                      (route) => false);
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text('Video Playback'),
        actions: [
          widget.scoreFilePath == null
              ? Container()
              : IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteVideo,
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: _chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _chewieController!.aspectRatio!,
                      child: Chewie(
                        controller: _chewieController!,
                      ),
                    )
                  : CircularProgressIndicator(),
            ),
            Consumer<ScoreProvider>(
              builder: (context, scoreProvider, child) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.scoreFilePath != null
                            ? _scores.map((score) {
                                return Text(
                                  '${score.description}  at ${score.time} - ${score.scorer}',
                                  style: TextStyle(
                                    color: score.color.value == Colors.red.value
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 16,
                                  ),
                                );
                              }).toList()
                            : scoreProvider.scores.map((score) {
                                return Text(
                                  '${score.description}  at ${score.time} - ${score.scorer}',
                                  style: TextStyle(
                                    color: score.color == Colors.red ? Colors.red : Colors.green,
                                    fontSize: 16,
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                    widget.scoreFilePath != null
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Red Scorer:${scoreProvider.totalScore1}',
                                  style: const TextStyle(color: Colors.red, fontSize: 20),
                                ),
                                Text(
                                  'Green Scorer: ${scoreProvider.totalScore2}',
                                  style: const TextStyle(color: Colors.green, fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                    // widget.scoreFilePath != null
                    //     ? Container()
                    //     : ElevatedButton(
                    //         onPressed: () => _showEndMatchDialog(context),
                    //         child: Text('End Match'),
                    //       ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

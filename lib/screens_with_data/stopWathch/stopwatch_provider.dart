import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

class StopwatchProvider with ChangeNotifier {
  late Stopwatch _stopwatch;
  late Timer _timer;
  List<String> _laps = [];
  Duration _lastLapTime = Duration.zero;
  String lapTimeStringData = "";
  StopwatchProvider() {
    _stopwatch = Stopwatch();
  }

  List<String> get laps => _laps;
  Duration get elapsedTime => _stopwatch.elapsed;

  void startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
        notifyListeners();
      });
    }
  }

  void stopStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer.cancel();
    }
  }

  void resetStopwatch() {
    _stopwatch.reset();
    _laps.clear();
    _lastLapTime = Duration.zero;
    notifyListeners();
  }

  void lapStopwatch() {
    if (_stopwatch.isRunning) {
      final currentTime = _stopwatch.elapsed;
      final lapTime = currentTime - _lastLapTime;
      _lastLapTime = currentTime;

      final lapTimeString = formatDuration(lapTime);
      final totalTimeString = formatDuration(currentTime);
      lapTimeStringData = lapTimeString;
      log('Lap  $lapTimeString');
      _laps.add(
          'Lap ${_laps.length + 1}: $lapTimeString (Total: $totalTimeString)');
      notifyListeners();
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = (duration.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    } else if (duration.inMinutes > 0) {
      return "$minutes:$seconds";
    } else {
      return "$seconds:$milliseconds";
    }
  }
}

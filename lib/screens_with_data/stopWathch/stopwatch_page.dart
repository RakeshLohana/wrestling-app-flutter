import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stopwatch_provider.dart';

class StopwatchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stopwatch with Laps'),
      ),
      body: Column(
        children: [
          SizedBox(height: 50),
          Center(
            child: Consumer<StopwatchProvider>(
              builder: (context, stopwatchProvider, child) {
                return Text(
                  stopwatchProvider.formatDuration(stopwatchProvider.elapsedTime),
                  style: TextStyle(fontSize: 48),
                );
              },
            ),
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => context.read<StopwatchProvider>().startStopwatch(),
                child: Text('Start'),
              ),
              ElevatedButton(
                onPressed: () => context.read<StopwatchProvider>().stopStopwatch(),
                child: Text('Stop'),
              ),
              ElevatedButton(
                onPressed: () => context.read<StopwatchProvider>().resetStopwatch(),
                child: Text('Reset'),
              ),
              ElevatedButton(
                onPressed: () => context.read<StopwatchProvider>().lapStopwatch(),
                child: Text('Lap'),
              ),
            ],
          ),
          SizedBox(height: 50),
          Expanded(
            child: Consumer<StopwatchProvider>(
              builder: (context, stopwatchProvider, child) {
                return ListView.builder(
                  itemCount: stopwatchProvider.laps.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(stopwatchProvider.laps[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

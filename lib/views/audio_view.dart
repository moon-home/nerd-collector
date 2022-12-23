import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nerdcollector/widgets/timer_widget.dart';

class AudioView extends StatefulWidget {
  const AudioView({Key? key}) : super(key: key);
  @override
  _AudioViewState createState() => _AudioViewState();
}

class _AudioViewState extends State<AudioView> {
  final timerController = TimerController();
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      await recorder.openRecorder();
      isRecorderReady = true;
      recorder.setSubscriptionDuration(
        const Duration(milliseconds: 500),
      );
    }
  }

  Future record() async {
    if (!isRecorderReady) return;
    if (recorder.isPaused) {
      await recorder.resumeRecorder();
    } else {
      await recorder.startRecorder(toFile: 'audio');
    }
    timerController.startTimer();
  }

  Future stop() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    print('Recorded audio: $audioFile');
    timerController.resetTimer();
  }

  Future pause() async {
    if (!isRecorderReady) return;
    await recorder.pauseRecorder();
    timerController.pauseTimer();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimerWidget(controller: timerController),
              /*StreamBuilder<RecordingDisposition>(
                stream: recorder.onProgress,
                builder: (context, snapshot) {
                  final duration = snapshot.hasData
                      ? snapshot.data!.duration
                      : Duration.zero;
                  // return Text('${duration.inSeconds} s');
                  String twoDigits(int n) => n.toString().padLeft(2, '0');
                  final twoDigitMinutes =
                      twoDigits(duration.inMinutes.remainder(60));
                  final twoDigitSeconds =
                      twoDigits(duration.inSeconds.remainder(60));
                  return Text(
                    '$twoDigitMinutes:$twoDigitSeconds',
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),*/
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (recorder.isRecording)
                    ElevatedButton(
                      child: const Icon(Icons.stop, size: 80),
                      onPressed: () async {
                        await stop();
                        setState(() {});
                      },
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    child: Icon(
                      recorder.isRecording ? Icons.pause : Icons.mic,
                      size: 80,
                    ),
                    onPressed: () async {
                      if (recorder.isRecording) {
                        await pause();
                      } else {
                        await record();
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoFromNetwork extends StatefulWidget {
  static const routeName = '/fromNetwork';
  final int courseId;
  final int? lessonId;
  final String videoUrl;

  const VideoFromNetwork({
    super.key,
    required this.courseId,
    this.lessonId,
    required this.videoUrl,
  });

  @override
  State<VideoFromNetwork> createState() => _VideoFromNetworkState();
}

class _VideoFromNetworkState extends State<VideoFromNetwork> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}



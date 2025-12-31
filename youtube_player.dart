import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class TaskYoutubePlayer extends StatefulWidget {
  final String youtubeUrl;

  const TaskYoutubePlayer({
    super.key,
    required this.youtubeUrl,
  });

  @override
  State<TaskYoutubePlayer> createState() => _TaskYoutubePlayerState();
}

class _TaskYoutubePlayerState extends State<TaskYoutubePlayer> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  String? _videoId;

  @override
  void initState() {
    super.initState();

    _videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);

    if (_videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          enableCaption: true,
          controlsVisibleAtStart: true,
          forceHD: false,
        ),
      )..addListener(_listener);
    }
  }

  void _listener() {
    if (_isPlayerReady) return;
    if (_controller.value.isReady) {
      setState(() => _isPlayerReady = true);
    }
  }

  @override
  void dispose() {
    if (_videoId != null) {
      _controller.dispose();
    }

  
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Invalid YouTube URL",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Learning Video",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          /// 🎬 PLAYER
          YoutubePlayerBuilder(
            onEnterFullScreen: () {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
            },
            onExitFullScreen: () {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
            },
            player: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                bufferedColor: Colors.white54,
                handleColor: Colors.redAccent,
              ),
              onReady: () {
                setState(() => _isPlayerReady = true);
              },
              onEnded: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Video completed"),
                  ),
                );
              },
            ),
            builder: (context, player) {
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              );
            },
          ),

         
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 20, 20, 20),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Tips",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "• Rotate your phone for fullscreen\n"
                      "• Make sure your internet is stable\n"
                      "• Video quality can be changed inside the player",
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

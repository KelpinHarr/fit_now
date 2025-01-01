import 'package:fit_now/constants.dart';
import 'package:fit_now/models/Video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WorkoutDetail extends StatefulWidget {
  final Video video;
  const WorkoutDetail({super.key, required this.video});

  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  String? videoId;
  YoutubePlayerController? _controller;

  @override
  void initState(){
    super.initState();
    videoId = YoutubePlayer.convertUrlToId(widget.video.url);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false
      )
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              }, 
              icon: Icon(
                Iconsax.arrow_left_2,
                color: white,
              )
            ),
            title: Text(
                'Workout',
                style: TextStyle(
                  color: orange,
                  fontFamily: 'ReadexPro-Medium',
                  fontWeight: FontWeight.w800,
                ),
              ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.video.creator} - ${widget.video.title}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ReadexPro-Medium'
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width - 50,
                child: YoutubePlayerBuilder(
                  player: YoutubePlayer(
                    controller: _controller!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: white,
                    progressColors: const ProgressBarColors(
                      playedColor: white,
                      handleColor: white
                    ),
                    onReady: (){
                      _controller!.addListener((){});
                    },
                    onEnded: (metadata) {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                    },
                  ), 
                  builder: (context, player){
                    return Column(
                      children: [
                        player
                      ],
                    );
                  }
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}
import 'package:fit_now/constants.dart';
import 'package:fit_now/models/Video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../bloc/workout_bloc.dart';
import '../bloc/workout_event.dart';
import '../bloc/workout_state.dart';

class WorkoutDetail extends StatefulWidget {
  final Video video;
  final String email;
  const WorkoutDetail({super.key, required this.video, required this.email});

  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  String? videoId;
  YoutubePlayerController? _controller;

  List<bool> checkboxStates = [];

  List<String> workoutItems = [];

  @override
  void initState() {
    super.initState();
    videoId = YoutubePlayer.convertUrlToId(widget.video.url);
    _controller = YoutubePlayerController(
        initialVideoId: videoId!,
        flags: YoutubePlayerFlags(autoPlay: false, mute: false
      )
    );

    workoutItems = widget.video.menu;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WorkoutBloc workoutBloc = BlocProvider.of<WorkoutBloc>(context);
    return Scaffold (
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
              onPressed: () {
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
        child: BlocBuilder<WorkoutBloc, WorkoutState>(
          builder: (context, state){
            return Padding(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.video.creator} - ${widget.video.title}',
                      style: TextStyle(
                        fontSize: 16,
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
                              playedColor: white, handleColor: white),
                          onReady: () {
                            _controller!.addListener(() {});
                          },
                          onEnded: (metadata) {
                            SystemChrome.setPreferredOrientations([
                              DeviceOrientation.portraitUp,
                              DeviceOrientation.portraitDown,
                            ]);
                          },
                        ),
                        builder: (context, player) {
                          return Column(
                            children: [player],
                          );
                        }
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Workout Menu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ReadexPro-Medium'
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: workoutItems.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 8, right: 20),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                workoutItems[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'ReadexPro-Medium',
                                  decoration: state.checkboxStates[index]
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              value: state.checkboxStates[index],
                              onChanged: (bool? value) {
                                context.read<WorkoutBloc>().add(
                                  UpdateCheckbox(
                                    index: index,
                                    value: value ?? false,
                                    videoUrl: widget.video.url,
                                    allCheckboxStates: List.generate(workoutItems.length, (index) => false)
                                  )
                                );
                                // setState(() {
                                //   checkboxStates[index] = value!;
                                // });
                              },
                              activeColor: orange,
                              checkColor: white,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    if (state.isCompleted)...[
                      Text(
                        'Great job! Workout completed!',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'ReadexPro-Medium',
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ]
                    else ...[
                      Text(
                        'Keep it up, ${state.remainingReps} reps left',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'ReadexPro-Medium',
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                    SizedBox(height: 30,)
                ],
              ),
            );
          },
        )
      ),
    );
  }
}

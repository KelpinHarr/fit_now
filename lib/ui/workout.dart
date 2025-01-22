import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/bloc/workout_bloc.dart';
import 'package:fit_now/components/bottom_navbar.dart';
import 'package:fit_now/constants.dart';
import 'package:fit_now/models/Video.dart';
import 'package:fit_now/ui/chat.dart';
import 'package:fit_now/ui/workout_detail.dart';
import 'package:fit_now/widgets/text_field_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class WorkoutPage extends StatefulWidget {
  final String email;
  const WorkoutPage({super.key, required this.email});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  int _currentIndex = 1;
  int _selectedFilterIndex = 0;
  Future<List<Video>>? _futureVideo;
  File? _video;
  final ImagePicker picker = ImagePicker();
  late final GenerativeModel _model, _visionModel;
  late final ChatSession _chat;

  final List<String> filters = [
    'Strength Training',
    'Cardio & Endurance',
    'Flexibility & Mobility'
  ];

  @override
  void initState(){
    super.initState();
    _futureVideo = _fetchVideoURL();

    _model = GenerativeModel(
      model: 'gemini-pro', 
      apiKey: 'AIzaSyAUx09EzgCiQ99NqxG8Fru2pT1RKF6bVf0'
    );

    _visionModel = GenerativeModel(
      model: 'gemini-vision-pro', 
      apiKey: 'AIzaSyAUx09EzgCiQ99NqxG8Fru2pT1RKF6bVf0'
    );

    _chat = _model.startChat();
  }

  Future<void> takeVideo(String name) async {
    try {
      var video = await picker.pickVideo(source: ImageSource.camera);

      if (video == null){
        return;
      }

      setState(() {
        _video = File(video.path);
      });

      _getAnalysisFromGemini(_video!.path, name);
    }
    catch(e){
      Fluttertoast.showToast(
        msg: 'Error :$e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.orange,
        fontSize: 14
      );
    }
  }

  Future<void> _getAnalysisFromGemini(String videoPath, String workoutName) async {
    try {
      final analysisPrompt = """
        Gemini, you are a workout personal trainer. You are the trainer for $workoutName. You must analyze the style and how user do the $workoutName. 

        This is the workout video: $videoPath

        Try to analyze and give a suggestion on how the player do the $workoutName from this video. Add the details description and suggestion from this video. Add some score for the $workoutName style and technique analysis both from 0 to 100.

        Make the result into a JSON format with schema like this schema:
        "{
          "response_suggestion": "Put your single paragraph analysis here",
          "style_score": Put your style score analysis here,
          "technique_score": Put your technique score analysis here
        }"

        Put the suggestion and analysis in the response_suggestion field, the style score from 0 to 100 into style_score field, and technique score from 0 to 100 into technique_score field.
      """;

      var content = Content.text(analysisPrompt);
      final response = await _chat.sendMessage(content);

      String cleanedResponse = response.text!
          .replaceAll('\n', '')
          .replaceAll('\n\n', '')
          .replaceAll('\r', '')
          .replaceAll('*', '')
          .replaceAll('**', '')
          .replaceFirst('```json', '')
          .replaceAll('```', '')
          .replaceFirst('JSON', '')
          .trim();
      
      final analysisResult = cleanedResponse;

      Map<String, dynamic> analysisData = jsonDecode(analysisResult);

      _displayAnalysisResult(analysisData['response_suggestion'], analysisData['style_score'], analysisData['technique_score']);
    }
    catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.orange,
        fontSize: 14
      );
    }
  }

  Future<void> _displayAnalysisResult(String response_suggestions, int style_score, int technique_score) async {
    showDialog(
      context: context, 
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Analysis Result',
          style: TextStyle(
            fontFamily: 'ReadexPro-Medium'
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Style Score: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'ReadexPro-Medium'
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$style_score/100',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ReadexPro-Medium'
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Technique Score: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'ReadexPro-Medium'
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$technique_score/100',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ReadexPro-Medium'
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Response Suggestions: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'ReadexPro-Medium'
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Text(
                      response_suggestions,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

  void _showDialog() async {
    final TextEditingController _workoutNameController = TextEditingController();

    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(
            'Workout Name',
            style: TextStyle(
              fontFamily: 'ReadexPro-Medium'
            ),
          ),
          backgroundColor: white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Input workout name to analyze your move',
                style: TextStyle(
                  fontFamily: 'ReadexPro-Medium'
                ),
              ),
              SizedBox(height: 10),
              TextFieldContainer(
                child: TextFormField(
                  controller: _workoutNameController,
                  cursorColor: orange,
                  decoration: InputDecoration(
                    icon: Icon(
                      Iconsax.weight_1,
                      color: orange,
                    ),
                    hintText: 'Workout Name',
                    hintStyle: TextStyle(
                      fontFamily: 'ReadexPro-Medium',
                    ),
                    border: InputBorder.none
                  )
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              }, 
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: blue
                ),
              )
            ),
            ElevatedButton(
              onPressed: () async {
                String workoutName = _workoutNameController.text.trim();
                if (workoutName.isNotEmpty){
                  Navigator.of(context).pop();
                  await takeVideo(workoutName);
                }
                else {
                  Fluttertoast.showToast(
                    msg: 'Please enter workout name.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 14,
                  );
                }
              }, 
              child: Text(
                'Submit',
                style: TextStyle(
                  color: white
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue
              ),
            )
          ],
        );
      }
    );
  }

  Future<List<Video>> _fetchVideoURL() async {
    List<Video> videos = [];
    try {
      final firestore = FirebaseFirestore.instance;
      final selectedFilter = filters[_selectedFilterIndex];
      final videoDocs = await firestore
          .collection('videos')
          .where('type', isEqualTo: selectedFilter)
          .get();
      if (videoDocs.docs.isNotEmpty){
        for (var video in videoDocs.docs){
          final data = video.data();
          final title = data['title'];
          final url = data['url'];
          final creator = data['creator'];
          final List<String> menu = (data['menu'] as List<dynamic>)
              .map((item) => item.toString())
              .toList();
              
          String videoId = '';

          if (url.contains("youtu.be")) {
            var parts = url.split('/');
            videoId = parts.last.split('?').first;
          }

          videos.add(Video(
            url: url, 
            title: title, 
            creator: creator,
            videoId: videoId,
            menu: menu
          ));
        }
      }
    }
    catch(e){
      Fluttertoast.showToast(
        msg: 'Error :$e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.orange,
        fontSize: 14
      );
    }
    return videos;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            title: Center(
              child: Text(
                'Workout',
                style: TextStyle(
                  color: orange,
                  fontFamily: 'ReadexPro-Medium',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: Text(
                    'Choose your focus!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ReadexPro-Medium',
                      fontSize: 16
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, right: 20),
                  child: IconButton(
                    onPressed: _showDialog,
                    icon: Icon(Iconsax.camera)
                  ),
                )
              ],
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: filters.asMap().entries.map((entry){
                    final index = entry.key;
                    final label = entry.value;
                
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            _selectedFilterIndex = index;
                            _futureVideo = _fetchVideoURL();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                          decoration: BoxDecoration(
                            color: _selectedFilterIndex == index ? orange : blue,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ReadexPro-Medium'
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 25),
            Expanded(
              child: FutureBuilder<List<Video>>(
                future: _futureVideo, 
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No videos found for this category.'));
                  } else {
                    final videos = snapshot.data!;

                    return ListView.separated(
                      itemCount: videos.length,
                      itemBuilder: (context, index){
                        final video = videos[index];
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => WorkoutBloc(
                                    initialCheckboxStates: List.generate(video.menu.length, (index) => false), 
                                    email: widget.email
                                  ),
                                  child: WorkoutDetail(video: video, email: widget.email),
                                )
                              )
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.network(
                                      video.thumbnailUrl,
                                      scale: 3.5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Text(
                                        'No workouts logged yet', //nanti fetch status dari db
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'ReadexPro-Medium'
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 15),
                                Text(
                                  '${video.creator} - ${video.title}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'ReadexPro-Medium'
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }, 
                      separatorBuilder: (context, index) => Divider(height: 30, thickness: 2,), 
                    );
                  }
                }
              )
            ),

          ],
        )
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentIndex = 2;
            });
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => ChatPage(email: widget.email)), 
            );
          },
          backgroundColor: darkBlue,
          child: Icon(
            Iconsax.messages_1, 
            color: _currentIndex == 2 ? orange : white,
            size: 35,
          ),
          shape: CircleBorder(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex, 
        onTabSelected: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        selectedColor: orange,
        unselectedColor: white,
        backgroundColor: darkBlue,
        email: widget.email,
      )
    );
  }
}
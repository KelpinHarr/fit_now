import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/bloc/workout_bloc.dart';
import 'package:fit_now/models/Video.dart';
import 'package:fit_now/models/WatchedVideo.dart';
import 'package:fit_now/models/Workout.dart';
import 'package:fit_now/ui/target_muscle_detail.dart';
import 'package:fit_now/ui/workout_detail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fit_now/components/bottom_navbar.dart';
import 'package:fit_now/constants.dart';
import 'package:fit_now/ui/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String email;
  final String? name;
  const HomePage({super.key, required this.email, this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _name = '';
  Future<List<Workout>>? _futureWorkout;
  Future<List<WatchedVideo>>? _futureWatchedVideo;
  SharedPreferences? _prefs;
  String? _selectedMuscle;

  @override
  void initState(){
    super.initState();
    getUser();
    _futureWatchedVideo = _watchedVideo();
    _loadSavedMuscle();
  }

  Future<void> _loadSavedMuscle() async {
    _prefs = await SharedPreferences.getInstance();
    final savedMuscle = _prefs?.getString('selectedMuscle');
    if (savedMuscle != null) {
      setState(() {
        _selectedMuscle = savedMuscle;
        _futureWorkout = fetchWorkout(savedMuscle);
      });
    }
  }

  Future<List<WatchedVideo>> _watchedVideo() async {
      List<WatchedVideo> watchedVideos = [];
      try {
        final firestore = FirebaseFirestore.instance;
        final userDocs = await firestore
            .collection('users')
            .where('email', isEqualTo: widget.email)
            .get();

        if (userDocs.docs.isNotEmpty) {
          final video = userDocs.docs.first;
          final List<dynamic> watchedVideoUrl = video['watched_videos'] ?? [];

          for (var videoUrl in watchedVideoUrl) {
            String videoId = '';
            if (videoUrl.contains("youtu.be")) {
              var parts = videoUrl.split('/');
              videoId = parts.last.split('?').first;
            }

            final videoDoc = await firestore
                .collection('videos')
                .where('url', isEqualTo: videoUrl)
                .get();
            
            if (videoDoc.docs.isNotEmpty){
              final videoData = videoDoc.docs.first.data();

              final video = Video(
                url: videoData['url'], 
                title: videoData['title'], 
                creator: videoData['creator'], 
                videoId: videoId, 
                menu: List<String>.from(videoData['menu'])
              );

              watchedVideos.add(WatchedVideo(video: video));
            }
          }
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: 'Error: $e',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            backgroundColor: Colors.orange,
            fontSize: 14);
      }
      return watchedVideos;
  }

  Future<void> getUser() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDocs = await firestore
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();
      if (userDocs.docs.isNotEmpty){
        final user = userDocs.docs.first;
        final name = user['name'];

        setState(() {
          _name = name;
        });
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
  }

  void _showCategoryDialog(BuildContext context) {
    String? selectedCategory;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...[
                        'Abdominals',
                        'Abductors',
                        'Adductor',
                        'Biceps',
                        'Calves',
                        'Chest',
                        'Forearms',
                        'Glutes',
                        'Hamstrings',
                        'Lower Back',
                        'Middle Back',
                        'Neck',
                        'Quadriceps',
                        'Traps',
                        'Triceps',
                      ].map((category) {
                        return RadioListTile<String>(
                          title: Text(
                            category,
                            style: TextStyle(color: white),
                          ),
                          value: category,
                          groupValue: selectedCategory,
                          onChanged: (String? value) {
                            setDialogState(() {
                              selectedCategory = value;
                            });
                          },
                          activeColor: orange,
                        );
                      }).toList(),
                      SizedBox(height: 20.0),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedCategory != null) {
                              setState(() {
                                _selectedMuscle = selectedCategory!.toLowerCase();
                                _futureWorkout = fetchWorkout(selectedCategory!.toLowerCase());
                              });
                              _prefs?.setString('selectedMuscle', selectedCategory!);
                              Navigator.pop(dialogContext);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Workout>> fetchWorkout(String workouts) async {
    List<Workout> workout = [];
    try {
      final url = Uri.parse("https://exercises-by-api-ninjas.p.rapidapi.com/v1/exercises");

      final headers = {
        "x-rapidapi-key" : "8db5a54b0emshbac83e362f217b9p12c273jsn16672e7e1ddd",
        "x-rapidapi-host" : "exercises-by-api-ninjas.p.rapidapi.com"
      };

      final params = {"muscle" : workouts};

      final response = await http.get(url.replace(queryParameters: params), headers: headers);

      if (response.statusCode == 200){
        final List<dynamic> data = jsonDecode(response.body);
        print(data);
        workout = data.map((item) => Workout(
          name: item['name'], 
          type: item['type'], 
          muscle: item['muscle'], 
          equipment: item['equipment'], 
          difficulty: item['difficulty'], 
          instructions: item['instructions']
        )).toList();
      }
      else {
        Fluttertoast.showToast(
          msg: 'Error :${response.statusCode}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: Colors.orange,
          fontSize: 14
        );
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
    return workout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 30, left: 20),
              child: _name == '' 
                ? Text(
                    'Welcome, ${widget.name}!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'ReadexPro-Medium',
                      fontWeight: FontWeight.bold
                    ),
                  )
                :
                Text(
                  'Welcome, ${_name}!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.bold
                  ),
                ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'It\'s a new day to achieve new milestones.\nLet\'s get moving!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ReadexPro-Medium'
                ),
              ),
            ),
            SizedBox(height: 35),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Your previous session',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'ReadexPro-Medium'
                ),
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: FutureBuilder<List<WatchedVideo>>(
                future: _futureWatchedVideo, 
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator());
                  }
                  else if (snapshot.hasError){
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  else if (!snapshot.hasData || snapshot.data!.isEmpty){
                    return Center(child: Text("There's no previous session"));
                  }
                  final videos = snapshot.data!;
                  return Container(
                    width: MediaQuery.of(context).size.width - 30,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: videos.length,
                        itemBuilder: (context, index){
                          final video = videos[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  // Navigator.push(
                                  //   context, 
                                  //   MaterialPageRoute(builder: (context) => WorkoutDetail(video: video.video, email: widget.email))
                                  // );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                        create: (context) => WorkoutBloc(
                                          initialCheckboxStates: List.generate(video.video.menu.length, (index) => false), 
                                          email: widget.email
                                        ),
                                        child: WorkoutDetail(video: video.video, email: widget.email),
                                      )
                                    )
                                  );
                                },
                                child: Image.network(
                                  video.thumbnailUrl,
                                  scale: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          );
                        }
                      ),
                    ),
                  );
                }
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Ready for a workout designed just for you? Our AI\ncan create custom plans based on your goals',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ReadexPro-Medium'
                ),
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Container(
                width: 300,
                child: ElevatedButton(
                  onPressed: (){
                    _showCategoryDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.fromHeight(55)
                  ),
                  child: Text(
                    'Choose your target muscle group',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'ReadexPro-Medium'
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Workout>>(
                future: _futureWorkout, 
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator());
                  }
                  else if (snapshot.hasError){
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  else if (!snapshot.hasData || snapshot.data!.isEmpty){
                    return Center(child: Text("There's no target muscle yet"));
                  }
                  final workouts = snapshot.data!;
                  return ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index){
                      final workout = workouts[index];
                      return Padding(
                        padding: EdgeInsets.only(left: 17, right: 17),
                        child: Card(
                          color: blue,
                          child: ListTile(
                            title: Text(
                              workout.name,
                              style: TextStyle(
                                color: white,
                                fontFamily: 'ReadexPro-Medium',
                                fontSize: 16
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                'Type: ${workout.type}\nMuscle: ${workout.muscle}',
                                style: TextStyle(
                                  fontFamily: 'ReadexPro-Medium',
                                  fontSize: 14,
                                  color: Colors.grey[400]
                                ),
                              ),
                            ),
                            trailing: Icon(
                              Iconsax.arrow_right_3,
                              color: white,
                            ),
                            onTap: (){
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => TargetMuscleDetailPage(workout: workout))
                              );
                            },
                          ),
                        ),
                      );
                    }
                  );
                }
              )
            )
          ],
        ),
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
              MaterialPageRoute(builder: (context) => ChatBotPage(email: widget.email)), 
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
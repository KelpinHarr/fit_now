import 'package:fit_now/components/bottom_navbar.dart';
import 'package:fit_now/constants.dart';
import 'package:fit_now/models/WatchedVideo.dart';
import 'package:fit_now/ui/chat.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/models/Video.dart';

class ReportPage extends StatefulWidget {
  final String email;
  const ReportPage({super.key, required this.email});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _currentIndex = 3;
  Future<List<WatchedVideo>>? _futureWatchedVideo;
  @override
  void initState() {
    super.initState();
    _futureWatchedVideo = _watchedVideo();
  }

  Future<String> _getMostWatchedCategory() async {
    try {
      final firestore = FirebaseFirestore.instance;
      QuerySnapshot userDocs = await firestore
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();
      if (userDocs.docs.isNotEmpty) {
        List<dynamic> watchedVideos =
            userDocs.docs.first['watched_videos'] ?? [];
        if (watchedVideos.isEmpty) {
          return "No videos watched.";
        }
        QuerySnapshot videosSnapshot =
            await firestore.collection('videos').get();
        Map<String, String> urlToCategory = {};
        for (var videoDoc in videosSnapshot.docs) {
          String? url = videoDoc['url'];
          String? category = videoDoc['type'];
          if (url != null && category != null) {
            urlToCategory[url] = category;
          }
        }
        Map<String, int> categoryCount = {};
        for (var videoUrl in watchedVideos) {
          String? category = urlToCategory[videoUrl];
          if (category != null) {
            categoryCount[category] = (categoryCount[category] ?? 0) + 1;
          }
        }

        String mostWatchedCategory = categoryCount.entries.fold(
          "",
          (prev, element) =>
              (categoryCount[prev] ?? 0) >= element.value ? prev : element.key,
        );

        return mostWatchedCategory.isNotEmpty
            ? "$mostWatchedCategory"
            : "No matching categories found.";
      }
      return '';
    } catch (e) {
      return 'Error: $e';
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

          if (videoDoc.docs.isNotEmpty) {
            final videoData = videoDoc.docs.first.data();

            final video = Video(
                url: videoData['url'],
                title: videoData['title'],
                creator: videoData['creator'],
                videoId: videoId,
                menu: List<String>.from(videoData['menu']));

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
                'Progress Tracking',
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
      backgroundColor: white,
      body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.height * 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30, left: 20),
                  child: Text(
                    "Monitor Your Progress, Set New Goals, and Keep Pushing Towards Your Best Self.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'ReadexPro-Medium',
                    ),
                  ),
                ),
                SizedBox(height: 5),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.34,
                  child: FutureBuilder<List<WatchedVideo>>(
                    future: _futureWatchedVideo,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text("There's no previous session"));
                      }
                      final videos = snapshot.data!;
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  videos.length.toString(),
                                  style: TextStyle(
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.video_library,
                                        color: Colors.orange),
                                    const SizedBox(width: 8.0),
                                    const Text('Videos Watched'),
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                FutureBuilder<String>(
                                  future: _getMostWatchedCategory(),
                                  builder: (context, categorySnapshot) {
                                    if (categorySnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (categorySnapshot.hasError) {
                                      return Text(
                                        'Error: ${categorySnapshot.error}',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.red,
                                        ),
                                      );
                                    } else if (categorySnapshot.hasData) {
                                      return Column(
                                        children: [
                                          Text(
                                            categorySnapshot.data!,
                                            style: TextStyle(
                                              fontSize: 32.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.category,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 8.0),
                                              const Text('Top Category'),
                                            ],
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Text(
                                        'No matching categories found.',
                                        style: TextStyle(fontSize: 16.0),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 16.0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 5),
                  child: Text(
                    "Activities",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'ReadexPro-Medium',
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: FutureBuilder<List<WatchedVideo>>(
                  future: _futureWatchedVideo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("There's no previous session"));
                    }
                    final videos = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          final video = videos[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Image.network(
                                            video.thumbnailUrl,
                                            scale: 5,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: 215,
                                              child: Text(
                                                video.title,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                              SizedBox(width: 10),
                            ],
                          );
                        }
                      ),
                    );
                  }
                ),
                )
              ],
            ),
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
              MaterialPageRoute(
                  builder: (context) => ChatPage(email: widget.email)),
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
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedColor: orange,
        unselectedColor: white,
        backgroundColor: darkBlue,
        email: widget.email,
      ),
    );
  }
}

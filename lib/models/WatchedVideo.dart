import 'package:fit_now/models/Video.dart';

class WatchedVideo {
  final Video video;

  WatchedVideo({
    required this.video
  });

  String get thumbnailUrl => "https://img.youtube.com/vi/${video.videoId}/hqdefault.jpg";
}
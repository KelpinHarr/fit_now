class WatchedVideo{
  final String url;
  final String video_id;

 WatchedVideo({
  required this.url,
  required this.video_id
 });

 String get thumbnailUrl => "https://img.youtube.com/vi/$video_id/hqdefault.jpg";
}
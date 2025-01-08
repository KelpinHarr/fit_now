class Video {
  final String url;
  final String title;
  final String creator;
  final String videoId;
  final List<String> menu;

  Video({
    required this.url,
    required this.title,
    required this.creator,
    required this.videoId,
    required this.menu
  });

  String get thumbnailUrl => "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
}
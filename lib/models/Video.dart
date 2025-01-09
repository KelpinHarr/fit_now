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

  factory Video.fromFirestore(Map<String, dynamic> data) {
    return Video(
      url: data['url'] ?? '',
      title: data['title'] ?? '',
      creator: data['creator'] ?? '',
      videoId: data['videoId'] ?? '',
      menu: List<String>.from(data['menu'] ?? []),
    );
  }
}
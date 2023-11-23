class RouteData {
  final String name;
  final String photoUrl;
  final String description;
  final String score;

  RouteData({
    required this.name,
    required this.photoUrl,
    required this.description,
    required this.score,
  });


  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      name: json['name'],
      photoUrl: json['photoUrl'] ?? '',
      description: json['description'],
      score: json['score'],
    );
  }
}

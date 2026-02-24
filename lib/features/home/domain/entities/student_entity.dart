class StudentEntity {
  final String handle;
  final String rating;
  final String rank;
  final Map<String, dynamic> ratingMatrix;
  final Map<String, dynamic> heatmap;
  final List<dynamic> recentSubmissions;

  const StudentEntity({
    required this.handle,
    required this.rating,
    required this.rank,
    required this.ratingMatrix,
    required this.heatmap,
    required this.recentSubmissions,
  });
}

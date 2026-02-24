import '../../domain/entities/student_entity.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.handle,
    required super.rating,
    required super.rank,
    required super.ratingMatrix,
    required super.heatmap,
    required super.recentSubmissions,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      handle: json['student'] ?? 'Unknown',
      rating: json['currentRating'].toString(),
      rank: json['rank'] ?? 'Unrated',
      ratingMatrix: json['ratingMatrix'] ?? {},
      heatmap: json['heatmap'] ?? {},
      recentSubmissions: json['recentSubmissions'] ?? [],
    );
  }
}

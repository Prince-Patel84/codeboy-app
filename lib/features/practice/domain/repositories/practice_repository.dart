import 'package:dartz/dartz.dart';

abstract class PracticeRepository {
  Future<Either<String, Map<String, dynamic>>> loadNextProblem(String handle);
  Future<Either<String, Map<String, dynamic>>> runCode({
    required String code,
    required String language,
    required String version,
    required String stdin,
  });
  Future<Either<String, Map<String, dynamic>>> submitCode({
    required String code,
    required String language,
    required String version,
    required List<Map<String, String>> testcases,
  });
}

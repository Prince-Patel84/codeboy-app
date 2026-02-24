import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/practice_repository.dart';
import '../../../../core/constants/api_constants.dart';

class PracticeRepositoryImpl implements PracticeRepository {
  final Dio client;
  
  final String baseUrl = ApiConstants.baseUrl; 

  PracticeRepositoryImpl(this.client);

  @override
  Future<Either<String, Map<String, dynamic>>> loadNextProblem(String handle) async {
    try {
      final response = await client.post(
        '$baseUrl/tutor/next-problem',
        data: {'handle': handle},
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(e.response?.data?['error'] ?? 'Network Error: Failed to load next problem.');
    } catch (e) {
      return Left('Unexpected Error: $e');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> runCode({
    required String code,
    required String language,
    required String version,
    required String stdin,
  }) async {
    try {
      final response = await client.post(
        '$baseUrl/run',
        data: {
          'code': code,
          'language': language,
          'version': version,
          'stdin': stdin,
        },
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(e.response?.data?['error'] ?? 'Network Error: Failed to execute code.');
    } catch (e) {
      return Left('Unexpected Error: $e');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> submitCode({
    required String code,
    required String language,
    required String version,
    required List<Map<String, String>> testcases,
  }) async {
    try {
      final response = await client.post(
        '$baseUrl/submit',
        data: {
          'code': code,
          'language': language,
          'version': version,
          'testcases': testcases,
        },
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(e.response?.data?['error'] ?? 'Network Error: Failed to submit code.');
    } catch (e) {
      return Left('Unexpected Error: $e');
    }
  }
}

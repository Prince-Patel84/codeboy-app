import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/student_model.dart';
import '../../../../core/constants/api_constants.dart';

class StudentRepositoryImpl implements StudentRepository {
  final Dio dio;
  StudentRepositoryImpl(this.dio);

  @override
  Future<Either<Failure, StudentEntity>> getStudentProfile(
    String handle,
  ) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/student/$handle',
      );

      if (response.statusCode == 200) {
        return Right(StudentModel.fromJson(response.data));
      } else {
        return const Left(ServerFailure('Failed to load profile'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

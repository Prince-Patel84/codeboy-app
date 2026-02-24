import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_entity.dart';

abstract class StudentRepository {
  Future<Either<Failure, StudentEntity>> getStudentProfile(String handle);
}

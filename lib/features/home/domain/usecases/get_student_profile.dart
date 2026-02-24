import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

class GetStudentProfile {
  final StudentRepository repository;

  GetStudentProfile(this.repository);

  Future<Either<Failure, StudentEntity>> call(String handle) async {
    return await repository.getStudentProfile(handle);
  }
}

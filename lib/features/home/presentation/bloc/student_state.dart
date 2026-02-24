import '../../domain/entities/student_entity.dart';

abstract class StudentState {}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final StudentEntity student;
  StudentLoaded(this.student);
}

class StudentError extends StudentState {
  final String message;
  StudentError(this.message);
}

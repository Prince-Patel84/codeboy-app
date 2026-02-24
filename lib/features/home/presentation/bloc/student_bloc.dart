import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_student_profile.dart';
import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final GetStudentProfile getStudentProfile;

  StudentBloc({required this.getStudentProfile}) : super(StudentInitial()) {
    on<FetchStudentProfile>((event, emit) async {
      emit(StudentLoading());
      final result = await getStudentProfile.call(event.handle);
      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (student) => emit(StudentLoaded(student)),
      );
    });
  }
}

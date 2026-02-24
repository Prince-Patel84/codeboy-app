abstract class StudentEvent {}

class FetchStudentProfile extends StudentEvent {
  final String handle;
  FetchStudentProfile(this.handle);
}

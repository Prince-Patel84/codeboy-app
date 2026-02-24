import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'features/home/data/repositories/student_repository.dart';
import 'features/home/domain/repositories/student_repository.dart';
import 'features/home/domain/usecases/get_student_profile.dart'; // Ensure you created this use case
import 'features/home/presentation/bloc/student_bloc.dart';
import 'features/practice/domain/repositories/practice_repository.dart';
import 'features/practice/data/repositories/practice_repository_impl.dart';
import 'features/practice/presentation/bloc/practice_bloc.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/send_chat_message.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(() => StudentBloc(getStudentProfile: sl()));
  sl.registerFactory(() => ChatBloc(sendChatMessage: sl()));
  sl.registerFactory(() => PracticeBloc(repository: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetStudentProfile(sl()));
  sl.registerLazySingleton(() => SendChatMessage(sl()));

  // Repositories
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton<PracticeRepository>(() => PracticeRepositoryImpl(sl()));

  // External - Global Dio instance
  sl.registerLazySingleton(() => Dio());
}

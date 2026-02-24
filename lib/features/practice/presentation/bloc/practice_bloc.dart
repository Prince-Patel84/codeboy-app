import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/practice_repository.dart';

// --- EVENTS ---
abstract class PracticeEvent {}

class LoadNextProblemEvent extends PracticeEvent {
  final String handle;
  LoadNextProblemEvent(this.handle);
}

class RunCodeEvent extends PracticeEvent {
  final String code;
  final String stdin;
  final String language;
  final String version;
  RunCodeEvent({required this.code, required this.stdin, required this.language, required this.version});
}

class SubmitCodeEvent extends PracticeEvent {
  final String code;
  final String language;
  final String version;
  final List<Map<String, String>> testcases;
  SubmitCodeEvent({required this.code, required this.language, required this.version, required this.testcases});
}

// --- STATES ---
abstract class PracticeState {}

class PracticeInitial extends PracticeState {}

class PracticeLoading extends PracticeState {
  final String message;
  PracticeLoading(this.message);
}

class PracticeProblemLoaded extends PracticeState {
  final String title;
  final String description;
  final int timeLimitMinutes;
  final int rating;
  final String reasoning;

  PracticeProblemLoaded({
    required this.title,
    required this.description,
    required this.timeLimitMinutes,
    required this.rating,
    required this.reasoning,
  });
}

class PracticeRunningCode extends PracticeState {}

class PracticeRunSuccess extends PracticeState {
  final String output;
  PracticeRunSuccess(this.output);
}

class PracticeRunError extends PracticeState {
  final String message;
  PracticeRunError(this.message);
}

class PracticeSubmitSuccess extends PracticeState {
  final String status;
  final int passed;
  final int total;
  final List<dynamic> results;

  PracticeSubmitSuccess({
    required this.status,
    required this.passed,
    required this.total,
    required this.results,
  });
}

class SubmissionRecord {
  final String code;
  final String language;
  final String status;
  final DateTime timestamp;

  SubmissionRecord({
    required this.code,
    required this.language,
    required this.status,
    required this.timestamp,
  });
}

// --- BLOC ---
class PracticeBloc extends Bloc<PracticeEvent, PracticeState> {
  final PracticeRepository repository;
  
  // We keep the loaded problem in memory to yield it back after a run/submit
  PracticeProblemLoaded? currentProblem;
  
  // Track submissions History
  List<SubmissionRecord> sessionSubmissions = [];

  PracticeBloc({required this.repository}) : super(PracticeInitial()) {
    on<LoadNextProblemEvent>(_onLoadNextProblem);
    on<RunCodeEvent>(_onRunCode);
    on<SubmitCodeEvent>(_onSubmitCode);
  }

  Future<void> _onLoadNextProblem(
      LoadNextProblemEvent event, Emitter<PracticeState> emit) async {
    emit(PracticeLoading("AI is analyzing your profile to pick the perfect problem..."));

    final result = await repository.loadNextProblem(event.handle);
    result.fold(
      (failure) => emit(PracticeRunError(failure)),
      (data) {
        currentProblem = PracticeProblemLoaded(
          title: data['title'] ?? 'Unknown Problem',
          description: data['description'] ?? 'No description provided.',
          timeLimitMinutes: data['timeLimitMinutes'] ?? 15,
          rating: data['rating'] ?? 800,
          reasoning: data['reasoning'] ?? 'Selected for your progressive overload.',
        );
        emit(currentProblem!);
      },
    );
  }

  Future<void> _onRunCode(
      RunCodeEvent event, Emitter<PracticeState> emit) async {
    emit(PracticeRunningCode());

    final result = await repository.runCode(
      code: event.code,
      language: event.language,
      version: event.version,
      stdin: event.stdin,
    );

    result.fold(
      (failure) {
        emit(PracticeRunError(failure));
        if (currentProblem != null) emit(currentProblem!);
      },
      (data) {
        if (data['status'] == 'Compilation Error') {
          emit(PracticeRunError(data['output']));
        } else {
          emit(PracticeRunSuccess(data['output'] ?? ''));
        }
        if (currentProblem != null) emit(currentProblem!);
      },
    );
  }

  Future<void> _onSubmitCode(
      SubmitCodeEvent event, Emitter<PracticeState> emit) async {
    emit(PracticeRunningCode()); // Re-use loading state

    final result = await repository.submitCode(
      code: event.code,
      language: event.language,
      version: event.version,
      testcases: event.testcases,
    );

    result.fold(
      (failure) {
        emit(PracticeRunError(failure));
        if (currentProblem != null) emit(currentProblem!);
      },
      (data) {
        final submission = SubmissionRecord(
          code: event.code,
          language: event.language,
          status: data['status'] == 'Compilation Error' ? 'Compilation Error' : data['status'],
          timestamp: DateTime.now(),
        );
        sessionSubmissions.add(submission);

        if (data['status'] == 'Compilation Error') {
          emit(PracticeRunError(data['output']));
        } else {
          emit(PracticeSubmitSuccess(
            status: data['status'],
            passed: data['passed'],
            total: data['total'],
            results: data['results'] ?? [],
          ));
        }
      },
    );
  }
}

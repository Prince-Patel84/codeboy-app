import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'features/home/presentation/bloc/student_bloc.dart';
import 'features/home/presentation/bloc/student_event.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/practice/presentation/bloc/practice_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'core/theme/codeforces_theme.dart';

// Global notifier for theme toggling
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Ensure Flutter is ready before calling async init
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  await di.init();

  // Check if user is logged in
  final prefs = await SharedPreferences.getInstance();
  final savedHandle = prefs.getString('cf_handle');
  final bool isLoggedIn = savedHandle != null && savedHandle.isNotEmpty;

  // Load saved theme preference
  final isDark = prefs.getBool('is_dark_mode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(CodeBoyApp(isLoggedIn: isLoggedIn, savedHandle: savedHandle));
}

class CodeBoyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? savedHandle;

  const CodeBoyApp({
    super.key,
    required this.isLoggedIn,
    this.savedHandle,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Initialize Student profile
        BlocProvider(
          create: (_) {
            final bloc = di.sl<StudentBloc>();
            if (isLoggedIn && savedHandle != null) {
              bloc.add(FetchStudentProfile(savedHandle!));
            }
            return bloc;
          }
        ),
        // Initialize ChatBloc for the AI Tutor component
        BlocProvider(create: (_) => di.sl<ChatBloc>()),
        // Initialize PracticeBloc for the Editor and Practice Logic
        BlocProvider(create: (_) => di.sl<PracticeBloc>()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, _) {
          return MaterialApp(
            title: 'CodeBoy - Learn to Code',
            debugShowCheckedModeBanner: false,
            theme: CodeforcesTheme.lightTheme,
            darkTheme: CodeforcesTheme.darkTheme,
            themeMode: currentMode,
            home: isLoggedIn ? const HomePage() : const LoginPage(),
          );
        },
      ),
    );
  }
}

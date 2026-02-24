import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../widgets/custom_nav_bar.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_state.dart';
import '../../../profile/presentation/widgets/hot_calendar.dart';
import '../../../profile/presentation/widgets/spider_diagram.dart';
import '../../../profile/presentation/widgets/rating_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _handle;

  @override
  void initState() {
    super.initState();
    _loadHandle();
  }

  Future<void> _loadHandle() async {
    final prefs = await SharedPreferences.getInstance();
    final handle = prefs.getString('cf_handle');
    
    if (handle == null || handle.isEmpty) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }
    
    setState(() {
      _handle = handle;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_handle == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(child: CustomNavBar(handle: _handle!)),
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading || state is StudentInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StudentError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text("Error loading profile: ${state.message}", style: const TextStyle(color: Colors.red, fontSize: 18)),
              )
            );
          } else if (state is StudentLoaded) {
            final student = state.student;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(4),
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                         ),
                         child: const CircleAvatar(
                           radius: 40,
                           backgroundColor: Colors.transparent,
                           child: Icon(Icons.person, size: 50),
                         ),
                       ),
                       const SizedBox(width: 20),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             student.handle, 
                             style: TextStyle(
                               fontSize: 28, 
                               fontWeight: FontWeight.bold,
                               color: _getRatingColor(student.rating, isDark),
                             )
                           ),
                           Text("${student.rank} • Rating: ${student.rating}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                         ],
                       ),
                       const Spacer(),
                       ElevatedButton.icon(
                         onPressed: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => PracticePage(handle: _handle!)),
                           );
                         },
                         icon: const Icon(Icons.rocket_launch),
                         label: const Text("Enter Practice Arena"),
                         style: ElevatedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                         ),
                       )
                     ]
                   ),
                   const SizedBox(height: 32),
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Expanded(child: RatingChart(handle: student.handle)),
                       const SizedBox(width: 16),
                       Expanded(child: SpiderDiagram(ratingMatrix: student.ratingMatrix, currentRating: student.rating)),
                     ],
                   ),
                   const SizedBox(height: 16),
                   HotCalendar(heatmapData: student.heatmap),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Color _getRatingColor(String ratingStr, bool isDark) {
    if (ratingStr == 'Unrated') return isDark ? Colors.white : Colors.black;
    final rating = int.tryParse(ratingStr) ?? 0;
    if (rating < 1200) return Colors.grey;
    if (rating < 1400) return Colors.green;
    if (rating < 1600) return Colors.cyan;
    if (rating < 1900) return Colors.blue;
    if (rating < 2100) return Colors.purple;
    if (rating < 2400) return Colors.orange;
    return Colors.red;
  }
}

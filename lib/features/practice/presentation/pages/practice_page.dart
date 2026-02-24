import 'package:flutter/material.dart';
import '../../../../features/chat/presentation/widgets/ai_tutor_chat.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codeboy/features/practice/presentation/bloc/practice_bloc.dart';
import 'dart:async';
import 'package:flutter_markdown/flutter_markdown.dart';

class PracticePage extends StatefulWidget {
  final String handle;
  
  const PracticePage({super.key, required this.handle});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late CodeController _codeController;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  bool _timerStarted = false;
  int _tabSpaces = 4; // Default tab spacing to 4 for C++
  
  String _selectedLangName = 'C++';
  String _selectedLangVersion = '10.2.0';

  final Map<String, Map<String, dynamic>> _supportedLanguages = {
    'C++': {
      'mode': cpp,
      'version': '10.2.0',
      'id': 'cpp',
      'template': '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Write your code here\n    return 0;\n}\n',
    },
    'Java': {
      'mode': java,
      'version': '15.0.2',
      'id': 'java',
      'template': 'import java.util.*;\n\npublic class Main {\n    public static void main(String[] args) {\n        // Write your code here\n    }\n}\n',
    },
    'Python': {
      'mode': python,
      'version': '3.10.0',
      'id': 'python',
      'template': 'def solve():\n    # Write your code here\n    pass\n\nif __name__ == "__main__":\n    solve()\n',
    },
    'Dart': {
      'mode': dart,
      'version': '3.3.3',
      'id': 'dart',
      'template': 'import \'dart:io\';\n\nvoid main() {\n  // Write your code here\n}\n',
    },
  };

  // Mock testcases fetched from problem
  final List<Map<String, String>> _problemTestcases = [
    {'input': '4\n1 5 3 2', 'output': '1'},
    {'input': '2\n10 10', 'output': '20'},
    {'input': '5\n1 2 3 4 5', 'output': '15'},
  ];

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: _supportedLanguages[_selectedLangName]!['template'],
      language: _supportedLanguages[_selectedLangName]!['mode'],
    );
    
    // Trigger problem load on entry
    context.read<PracticeBloc>().add(LoadNextProblemEvent(widget.handle));
  }

  void _startTimer(int minutes) {
    if (_countdownTimer != null && _countdownTimer!.isActive) return;
    setState(() {
      _remainingSeconds = minutes * 60;
      _timerStarted = true;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final m = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _applyTemplate() {
    _codeController.text = _supportedLanguages[_selectedLangName]!['template'];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<PracticeBloc, PracticeState>(
      listener: (context, state) {
        if (state is PracticeProblemLoaded) {
          // Do not auto-start timer anymore
          if (!_timerStarted && _remainingSeconds == 0) {
             _remainingSeconds = state.timeLimitMinutes * 60;
          }
        } else if (state is PracticeRunError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
          );
        } else if (state is PracticeSubmitSuccess) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submit Status: ${state.status} (${state.passed}/${state.total})')),
          );
        }
      },
      builder: (context, state) {
        final currentProblem = context.read<PracticeBloc>().currentProblem;
        final bool isLoading = state is PracticeLoading || state is PracticeRunningCode;
        
        return Scaffold(
          appBar: _buildAppBar(currentProblem, isLoading),
          body: state is PracticeLoading 
            ? const Center(child: CircularProgressIndicator())
            : Row(
              children: [
                // Left Panel: Problem & AI Tutor Tabs
                Expanded(
                  flex: 4,
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                         if (isLoading && state is PracticeRunningCode)
                            const LinearProgressIndicator(),
                        TabBar(
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).primaryColor,
                          tabs: const [
                            Tab(icon: Icon(Icons.description), text: "Description"),
                            Tab(icon: Icon(Icons.auto_awesome), text: "AI Tutor"),
                            Tab(icon: Icon(Icons.history), text: "Submissions"),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildProblemDescription(currentProblem, isDark),
                              AiTutorChat(
                                codeController: _codeController, 
                                problemTitle: currentProblem?.title ?? "Problem"
                              ),
                              _buildSubmissionsTab(context, isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
                // Right Panel: Editor & Test Case Results
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      // Editor Toolbar
                      Container(
                        color: isDark ? Colors.black26 : Colors.grey[200],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            DropdownButton<String>(
                              value: _selectedLangName,
                              underline: const SizedBox(),
                              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                              items: _supportedLanguages.keys.map((lang) {
                                return DropdownMenuItem(value: lang, child: Text(lang));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedLangName = val;
                                    _selectedLangVersion = _supportedLanguages[val]!['version'];
                                    _codeController.language = _supportedLanguages[val]!['mode'];
                                    _applyTemplate();
                                  });
                                }
                              },
                            ),
                            const Spacer(),
                            Text("Tab Size: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                            DropdownButton<int>(
                              value: _tabSpaces,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 2, child: Text("2")),
                                DropdownMenuItem(value: 4, child: Text("4")),
                                DropdownMenuItem(value: 8, child: Text("8")),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _tabSpaces = val);
                              },
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.restore_page),
                              tooltip: "Reset to Template",
                              onPressed: _applyTemplate,
                            ),
                          ],
                        ),
                      ),
                      // Code Editor
                      Expanded(
                        flex: 6,
                        child: CodeTheme(
                          data: CodeThemeData(styles: monokaiSublimeTheme),
                          child: SingleChildScrollView(
                            child: CodeField(
                              controller: _codeController,
                              textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: Theme.of(context).dividerColor),
                      // Test Cases Panel (LeetCode Style)
                      Expanded(
                        flex: 4,
                        child: _buildTestcasePanel(state, isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(PracticeProblemLoaded? currentProblem, bool isLoading) {
    return AppBar(
      title: Row(
        children: [
          const Text('CodeBoy Workspace'),
          const SizedBox(width: 20),
          if (currentProblem != null)
             InkWell(
               onTap: () {
                 if (!_timerStarted) {
                   _startTimer(currentProblem.timeLimitMinutes);
                 }
               },
               borderRadius: BorderRadius.circular(12),
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                 decoration: BoxDecoration(
                   color: _timerStarted 
                      ? (_remainingSeconds < 300 ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2))
                      : Colors.orange.withValues(alpha: 0.2),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: _timerStarted 
                      ? (_remainingSeconds < 300 ? Colors.red : Colors.green)
                      : Colors.orange),
                 ),
                 child: Row(
                   children: [
                     Icon(
                       _timerStarted ? Icons.timer : Icons.play_circle_fill,
                       size: 16,
                       color: _timerStarted 
                          ? (_remainingSeconds < 300 ? Colors.redAccent : Colors.green)
                          : Colors.orange,
                     ),
                     const SizedBox(width: 8),
                     Text(
                       _timerStarted ? _formattedTime : "Start Timer (${currentProblem.timeLimitMinutes}m)",
                       style: TextStyle(
                         color: _timerStarted 
                            ? (_remainingSeconds < 300 ? Colors.redAccent : Colors.green)
                            : Colors.orange,
                         fontWeight: FontWeight.bold,
                         fontFamily: 'monospace',
                       ),
                     ),
                   ],
                 ),
               ),
             ),
        ]
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.green),
          onPressed: isLoading ? null : () {
            context.read<PracticeBloc>().add(RunCodeEvent(
              code: _codeController.text,
              stdin: _problemTestcases.first['input']!, 
              language: _supportedLanguages[_selectedLangName]!['id'],
              version: _selectedLangVersion,
            ));
          },
          tooltip: "Run First Testcase",
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () {
              context.read<PracticeBloc>().add(SubmitCodeEvent(
                code: _codeController.text,
                language: _supportedLanguages[_selectedLangName]!['id'],
                version: _selectedLangVersion,
                testcases: _problemTestcases,
              ));
            },
            icon: const Icon(Icons.cloud_upload),
            label: const Text("Submit"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProblemDescription(PracticeProblemLoaded? currentProblem, bool isDark) {
    if (currentProblem == null) {
      return const Center(child: Text("Loading problem details..."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  currentProblem.title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Text(
                  "Rating: ${currentProblem.rating}",
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // AI Reasoning Alert
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.blueGrey.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.psychology, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "CodeBoy Selected This Because: ${currentProblem.reasoning}",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          MarkdownBody(
            data: currentProblem.description,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16, height: 1.6),
              code: TextStyle(
                backgroundColor: isDark ? Colors.black45 : Colors.grey[200],
                fontFamily: 'monospace',
              ),
              codeblockDecoration: BoxDecoration(
                color: isDark ? Colors.black45 : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Examples", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._problemTestcases.asMap().entries.map((entry) {
            int idx = entry.key + 1;
            var tc = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isDark ? Colors.white10 : Colors.grey[100],
                    child: Text("Test Case $idx", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Input:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(tc['input']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
                        const SizedBox(height: 16),
                        const Text("Output:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(tc['output']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubmissionsTab(BuildContext context, bool isDark) {
    final submissions = context.read<PracticeBloc>().sessionSubmissions;
    
    if (submissions.isEmpty) {
      return Center(
        child: Text(
          "No submissions yet.\\nHit Submit to evaluate your code!",
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: submissions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        // Show newest first
        final sub = submissions[submissions.length - 1 - index];
        final isAccepted = sub.status == 'Accepted';
        
        return Card(
          elevation: 0,
          color: isDark ? Colors.white10 : Colors.grey[50],
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: Text(
              sub.status,
              style: TextStyle(
                color: isAccepted ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Language: ${sub.language} | Time: ${sub.timestamp.toLocal().toString().split('.')[0]}",
              style: const TextStyle(fontSize: 12),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: isDark ? Colors.black45 : Colors.grey[200],
                child: Text(
                  sub.code,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestcasePanel(PracticeState state, bool isDark) {
    return DefaultTabController(
      length: _problemTestcases.length + 1, // Cases + Console
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: isDark ? const Color(0xFF2D2D30) : const Color(0xFFF0F0F0),
            child: TabBar(
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                const Tab(text: "Console"),
                ...List.generate(_problemTestcases.length, (index) => Tab(text: "Case ${index + 1}")),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: TabBarView(
                children: [
                  // Console Output Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _getConsoleOut(state),
                        style: TextStyle(fontFamily: 'monospace', color: _getConsoleColor(state, isDark)),
                      ),
                    ),
                  ),
                  // Test Cases Tabs
                  ..._problemTestcases.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final tc = entry.value;
                    
                    // Default state just shows the input/expected
                    String actualLabel = "Click 'Submit' to see actual output against all test cases.";
                    Color actualColor = Colors.grey;
                    
                    if (state is PracticeSubmitSuccess && state.results.length > idx) {
                       final res = state.results[idx];
                       actualLabel = res['actual'] ?? '';
                       actualColor = res['passed'] ? Colors.green : Colors.red;
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Input", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: Text(tc['input']!, style: const TextStyle(fontFamily: 'monospace')),
                          ),
                          const SizedBox(height: 16),
                          const Text("Expected Output", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: Text(tc['output']!, style: const TextStyle(fontFamily: 'monospace')),
                          ),
                          const SizedBox(height: 16),
                          const Text("Actual Output", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: Text(actualLabel, style: TextStyle(fontFamily: 'monospace', color: actualColor)),
                          ),
                        ],
                      ),
                    );
                  })
                ]
              )
            ),
          ),
        ],
      ),
    );
  }

  String _getConsoleOut(PracticeState state) {
    if (state is PracticeRunSuccess) return state.output;
    if (state is PracticeSubmitSuccess) return "Verdict: ${state.status}\nPassed: ${state.passed}/${state.total}";
    if (state is PracticeRunningCode) return "Running Code on Piston...";
    if (state is PracticeRunError) return state.message;
    return "Hit Run to test your code, or Submit to run against all logic cases.";
  }

  Color _getConsoleColor(PracticeState state, bool isDark) {
    if (state is PracticeRunError) return Colors.red;
    if (state is PracticeSubmitSuccess) return state.status == 'Accepted' ? Colors.green : Colors.red;
    return isDark ? Colors.white70 : Colors.black87;
  }
}

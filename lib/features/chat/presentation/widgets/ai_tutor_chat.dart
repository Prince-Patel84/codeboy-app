import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../bloc/chat_bloc.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

class AiTutorChat extends StatefulWidget {
  final CodeController codeController;
  final String problemTitle;

  const AiTutorChat({
    super.key,
    required this.codeController,
    required this.problemTitle,
  });

  @override
  State<AiTutorChat> createState() => _AiTutorChatState();
}

class _AiTutorChatState extends State<AiTutorChat> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state.messages.isEmpty) {
                return const Center(
                  child: Text(
                    "Hi! I'm CodeBoy AI.\\nI can see your editor code in real-time. Ask me anything!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final msg = state.messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: msg.isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.isAI) ...[
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(Icons.smart_toy, size: 20, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: msg.isAI 
                                  ? (isDark ? Colors.grey[850] : Colors.grey[200])
                                  : Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(16).copyWith(
                                topLeft: msg.isAI ? const Radius.circular(0) : const Radius.circular(16),
                                topRight: msg.isAI ? const Radius.circular(16) : const Radius.circular(0),
                              ),
                            ),
                            child: msg.isAI 
                              ? MarkdownBody(
                                  data: msg.text,
                                  selectable: true,
                                  styleSheet: MarkdownStyleSheet(
                                    code: TextStyle(
                                      fontFamily: 'monospace',
                                      backgroundColor: isDark ? Colors.black45 : Colors.black12,
                                    ),
                                    codeblockDecoration: BoxDecoration(
                                      color: isDark ? Colors.black87 : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                )
                              : Text(
                                  msg.text,
                                  style: const TextStyle(color: Colors.white),
                                ),
                          ),
                        ),
                        if (!msg.isAI) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).primaryColorDark,
                            child: const Icon(Icons.person, size: 20, color: Colors.white),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (context.watch<ChatBloc>().state.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(),
          ),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Ask CodeBoy about your code...",
                    filled: true,
                    fillColor: isDark ? Colors.black26 : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onSubmitted: (_) => _sendMessage(context),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _sendMessage(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage(BuildContext context) {
    if (_controller.text.trim().isEmpty) return;
    
    // Auto-inject the exact code from the editor
    final currentCode = widget.codeController.text;
    
    context.read<ChatBloc>().add(
      SendNewMessage(_controller.text, currentCode),
    );
    _controller.clear();
  }
}

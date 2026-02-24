import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/send_chat_message.dart';

// Events
abstract class ChatEvent {}

class SendNewMessage extends ChatEvent {
  final String message;
  final String code;
  SendNewMessage(this.message, this.code);
}

// States
class ChatState {
  final List<ChatMessageEntity> messages;
  final bool isLoading;
  ChatState({required this.messages, this.isLoading = false});
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendChatMessage sendChatMessage;

  ChatBloc({required this.sendChatMessage}) : super(ChatState(messages: [])) {
    on<SendNewMessage>((event, emit) async {
      final updatedMessages = List<ChatMessageEntity>.from(state.messages)
        ..add(ChatMessageEntity(text: event.message, isAI: false));

      emit(ChatState(messages: updatedMessages, isLoading: true));

      final result = await sendChatMessage.call(
        handle: "Prince_Patel84", // Pull this from your Auth/Student Bloc later
        problemName: "String Rotation Game",
        code: event.code,
        userMessage: event.message,
      );

      result.fold(
        (failure) =>
            emit(ChatState(messages: updatedMessages, isLoading: false)),
        (aiReply) {
          updatedMessages.add(aiReply);
          emit(ChatState(messages: updatedMessages, isLoading: false));
        },
      );
    });
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class SendChatMessage {
  final ChatRepository repository;
  SendChatMessage(this.repository);

  Future<Either<Failure, ChatMessageEntity>> call({
    required String handle,
    required String problemName,
    required String code,
    required String userMessage,
  }) async {
    return await repository.sendMessage(
      handle: handle,
      problemName: problemName,
      code: code,
      userMessage: userMessage,
    );
  }
}

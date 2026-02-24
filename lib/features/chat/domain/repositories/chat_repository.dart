import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String handle,
    required String problemName,
    required String code,
    required String userMessage,
  });
}

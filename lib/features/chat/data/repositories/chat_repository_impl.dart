import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/constants/api_constants.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio dio;
  ChatRepositoryImpl(this.dio);

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String handle,
    required String problemName,
    required String code,
    required String userMessage,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/tutor/chat',
        data: {
          'handle': handle,
          'problemName': problemName,
          'code': code,
          'userMessage': userMessage,
        },
      );

      if (response.statusCode == 200) {
        return Right(
          ChatMessageEntity(text: response.data['reply'], isAI: true),
        );
      } else {
        return const Left(ServerFailure('The AI tutor is unavailable.'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

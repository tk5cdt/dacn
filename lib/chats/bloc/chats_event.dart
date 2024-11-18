part of 'chats_bloc.dart';

sealed class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object> get props => [];
}

final class ChatsSubscriptionRequested extends ChatsEvent {
  const ChatsSubscriptionRequested({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

final class ChatsCreateChatRequested extends ChatsEvent {
  const ChatsCreateChatRequested({
    required this.userId,
    required this.participantId,
  });

  final String userId;
  final String participantId;

  @override
  List<Object> get props => [userId, participantId];
}

final class ChatsDeleteChatRequested extends ChatsEvent {
  const ChatsDeleteChatRequested({
    required this.userId,
    required this.chatId,
  });

  final String userId;
  final String chatId;

  @override
  List<Object> get props => [userId, chatId];
}

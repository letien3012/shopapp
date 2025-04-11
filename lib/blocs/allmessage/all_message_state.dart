import 'package:luanvan/models/message.dart';

abstract class AllMessageState {}

class AllMessageInitial extends AllMessageState {}

class AllMessageLoading extends AllMessageState {}

class AllMessageLoaded extends AllMessageState {
  final List<Message> messages;
  AllMessageLoaded(this.messages);
}

class AllMessageError extends AllMessageState {
  final String message;
  AllMessageError(this.message);
}

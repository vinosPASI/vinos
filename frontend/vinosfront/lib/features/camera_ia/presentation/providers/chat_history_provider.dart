import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChatMessageType { bot, image, loading, error }

class ChatMessage {
  final ChatMessageType type;
  final String? text;
  final File? image;
  final DateTime timestamp;

  ChatMessage({
    required this.type,
    this.text,
    this.image,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatHistoryNotifier extends StateNotifier<List<ChatMessage>> {
  ChatHistoryNotifier()
      : super([
          ChatMessage(
            type: ChatMessageType.bot,
            text:
                "Hola, Toma una foto o selecciona una imagen de la galería para comenzar el análisis.",
          ),
        ]);

  void addBotMessage(String text) {
    state = [
      ...state.where((m) => m.type != ChatMessageType.loading),
      ChatMessage(type: ChatMessageType.bot, text: text),
    ];
  }

  void addImageMessage(File image) {
    state = [...state, ChatMessage(type: ChatMessageType.image, image: image)];
  }

  void addLoadingMessage() {
    if (!state.any((m) => m.type == ChatMessageType.loading)) {
      state = [
        ...state,
        ChatMessage(type: ChatMessageType.loading),
      ];
    }
  }

  void addErrorMessage(String error) {
    state = [
      ...state.where((m) => m.type != ChatMessageType.loading),
      ChatMessage(type: ChatMessageType.error, text: error),
    ];
  }

  void removeLoading() {
    state = state.where((m) => m.type != ChatMessageType.loading).toList();
  }

  void clearHistory() {
    state = [
      ChatMessage(
        type: ChatMessageType.bot,
        text:
            "Hola, Toma una foto o selecciona una imagen de la galería para comenzar el análisis.",
      ),
    ];
  }
}

final chatHistoryProvider =
    StateNotifierProvider<ChatHistoryNotifier, List<ChatMessage>>(
  (ref) => ChatHistoryNotifier(),
);
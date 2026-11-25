import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../mock_data/assistant_replies.dart';
import '../models/chat_message.dart';
import '../models/vehicle.dart';

class AssistantProvider extends ChangeNotifier {
  AssistantProvider({this.replyDelay = const Duration(milliseconds: 600)});

  final Duration replyDelay;
  final List<ChatMessage> _messages = [
    const ChatMessage.ai(assistantGreeting, showDisclaimer: false),
  ];
  bool _thinking = false;
  bool _disposed = false;
  int _chatId = 0;

  List<ChatMessage> get messages => UnmodifiableListView(_messages);
  bool get thinking => _thinking;

  Future<void> ask(String question, List<VehicleData> vehicles) async {
    final text = question.trim();
    if (text.isEmpty || _thinking) return;

    final chatId = _chatId;
    _messages.add(ChatMessage.user(text));
    _thinking = true;
    notifyListeners();

    if (replyDelay > Duration.zero) await Future.delayed(replyDelay);
    if (_disposed || chatId != _chatId) return; // chat was reset meanwhile

    _messages.add(ChatMessage.ai(buildAssistantReply(text, vehicles)));
    _thinking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void newChat() {
    _chatId++;
    _messages
      ..clear()
      ..add(const ChatMessage.ai(assistantGreeting, showDisclaimer: false));
    _thinking = false;
    notifyListeners();
  }
}

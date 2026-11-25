class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.fromUser,
    this.showDisclaimer = false,
  });

  const ChatMessage.user(String text) : this(text: text, fromUser: true);

  const ChatMessage.ai(String text, {bool showDisclaimer = true})
    : this(text: text, fromUser: false, showDisclaimer: showDisclaimer);

  final String text;
  final bool fromUser;
  final bool showDisclaimer;
}

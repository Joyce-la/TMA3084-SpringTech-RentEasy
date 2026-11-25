import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:src/providers/assistant_provider.dart';
import 'package:src/providers/fleet_provider.dart';

import '../../models/chat_message.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  /// Call this from any screen's AI icon.
  static Future<void> open(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const AiAssistantScreen()),
    );
  }

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  static const Color navyBlue = Color(0xFF071957);
  static const Color bubbleGrey = Color(0xFFF1F1F5);
  static const Color userGrey = Color(0xFFD9D9D9);

  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    final assistant = context.read<AssistantProvider>();
    final vehicles = context.read<FleetProvider>().vehicles;
    final future = assistant.ask(text, vehicles);
    _scrollToEnd();
    await future;
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<AssistantProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.chevron_left, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildNewChatButton(assistant),
                ],
              ),
            ),
            _buildSuggestions(),
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount:
                    assistant.messages.length + (assistant.thinking ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == assistant.messages.length) {
                    return _buildBubble(
                      const ChatMessage.ai(
                        'Thinking...',
                        showDisclaimer: false,
                      ),
                    );
                  }
                  return _buildBubble(assistant.messages[index]);
                },
              ),
            ),
            _buildInputBar(assistant),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatButton(AssistantProvider assistant) {
    final canReset = assistant.messages.length > 1 || assistant.thinking;

    return Tooltip(
      message: 'New chat',
      child: GestureDetector(
        onTap: canReset
            ? () => context.read<AssistantProvider>().newChat()
            : null,
        child: CircleAvatar(
          radius: 17,
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.add_comment_outlined,
            size: 19,
            color: canReset ? Colors.black : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _suggestion(Icons.directions_car, 'Available vehicles today'),
          _suggestion(Icons.warning_amber_rounded, 'Overdue rentals'),
          _suggestion(Icons.edit_outlined, 'QAA 1234 history'),
        ],
      ),
    );
  }

  Widget _suggestion(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _send(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bubbleGrey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage message) {
    if (message.fromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: userGrey,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(message.text, style: const TextStyle(fontSize: 14)),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: userGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'AI',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bubbleGrey,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.text, style: const TextStyle(fontSize: 14)),
                if (message.showDisclaimer) ...[
                  const SizedBox(height: 10),
                  Text(
                    'AI-generated content may be inaccurate. Please verify '
                    'when necessary.',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(AssistantProvider assistant) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 6, 6, 6),
        decoration: BoxDecoration(
          color: userGrey,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Voice input',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFC4C4D0),
              ),
              icon: const Icon(Icons.mic, color: Colors.black87),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voice input is not available yet.'),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Send',
              style: IconButton.styleFrom(
                backgroundColor: navyBlue,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.arrow_upward),
              onPressed: assistant.thinking
                  ? null
                  : () => _send(_controller.text),
            ),
          ],
        ),
      ),
    );
  }
}

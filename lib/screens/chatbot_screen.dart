import 'package:flutter/material.dart';
import '../widgets/localized_text.dart';
import '../services/api_service.dart';
import '../services/language_controller.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  static const _purple = Color(0xFF5420E6);
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;

  final _suggestions = const [
    'I clicked a phishing link. What should I do?',
    'How can I identify a fake bank message?',
    'Why is my scanned URL suspicious?',
    'How do I protect my accounts?',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final messages = await ApiService.chatHistory();
      if (mounted) setState(() => _messages = messages);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: LocalizedText(
                  'Could not load the assistant. Check the backend.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? suggested]) async {
    final text = (suggested ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();
    setState(() {
      _sending = true;
      _messages.add({'role': 'user', 'content': text, 'provider': 'app'});
    });
    _scrollToEnd();
    try {
      final reply = await ApiService.sendChatMessage(text);
      if (mounted) setState(() => _messages.add(reply));
    } catch (_) {
      if (mounted) {
        setState(() => _messages.add({
              'role': 'assistant',
              'content':
                  'I could not reach the assistant service. Confirm that the backend is running and try again.',
              'provider': 'error',
            }));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToEnd();
    }
  }

  Future<void> _clear() async {
    await ApiService.clearChatHistory();
    if (mounted) setState(() => _messages.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            LocalizedText('Nirapod Guide',
                style: TextStyle(fontWeight: FontWeight.w800)),
            LocalizedText('AI cybersecurity assistant',
                style: TextStyle(fontSize: 12)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: AppLanguageController.translate('Clear conversation'),
            onPressed: _messages.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const LocalizedText(
                'Do not share passwords, OTPs, card numbers, private keys, or recovery codes. AI guidance can make mistakes—verify important actions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
            if (_messages.isEmpty && !_loading)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions
                      .map((suggestion) => ActionChip(
                            label: LocalizedText(suggestion),
                            onPressed: () => _send(suggestion),
                          ))
                      .toList(),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_sending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return const _TypingBubble();
                        }
                        return _ChatBubble(message: _messages[index]);
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 4000,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: AppLanguageController.translate(
                            'Ask any security question…'),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final Map<String, dynamic> message;

  @override
  Widget build(BuildContext context) {
    final user = message['role'] == 'user';
    final provider = message['provider'] as String? ?? '';
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: user
              ? const Color(0xFF5420E6)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocalizedText(
              message['content'] as String,
              style: TextStyle(color: user ? Colors.white : null, height: 1.4),
            ),
            if (!user && provider.isNotEmpty) ...[
              const SizedBox(height: 7),
              LocalizedText(
                provider == 'openai'
                    ? 'Online AI'
                    : provider == 'error'
                        ? 'Connection error'
                        : 'Local security guide',
                style: TextStyle(
                    fontSize: 10,
                    color: user ? Colors.white70 : Theme.of(context).hintColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10),
            LocalizedText('Thinking…'),
          ],
        ),
      ),
    );
  }
}

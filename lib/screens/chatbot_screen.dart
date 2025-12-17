import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chatbot_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/chatbot/chat_bubble_user.dart';
import '../widgets/chatbot/chat_bubble_bot.dart';
import '../widgets/chatbot/typing_indicator.dart';
import '../widgets/chatbot/chat_input_field.dart';
import '../widgets/chatbot/quick_action_buttons.dart';
import '../models/chat_suggestions_model.dart';
import '../widgets/chatbot/suggestion_chip_widget.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showWelcome = false;
  bool _showSuggestions = true;
  String? _selectedSuggestionCategory;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatbotProvider = context.read<ChatbotProvider>();
      final gameProvider = context.read<GameProvider>();

      // Set game provider for context injection
      chatbotProvider.setGameProvider(gameProvider);

      // Show welcome message if no messages
      if (!chatbotProvider.hasMessages) {
        setState(() {
          _showWelcome = true;
        });
      }

      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _handleSuggestionTap(ChatSuggestion suggestion) {
    setState(() {
      _selectedSuggestionCategory = suggestion.id;
    });

    // If has sub-items, show bottom sheet
    if (suggestion.hasSubItems) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SuggestionBottomSheet(
          parentSuggestion: suggestion,
          onSuggestionSelected: _handleSubSuggestionTap,
        ),
      );
    } else if (suggestion.fullResponse != null) {
      // Direct response - send as user question and show response
      _sendSuggestionResponse(suggestion);
    }
  }

  void _handleSubSuggestionTap(ChatSuggestion suggestion) {
    if (suggestion.fullResponse != null) {
      _sendSuggestionResponse(suggestion);
    }
  }

  void _sendSuggestionResponse(ChatSuggestion suggestion) {
    final provider = context.read<ChatbotProvider>();

    // Send as user message first
    provider.sendTextMessage(suggestion.title);

    // Then send bot response with full content
    Future.delayed(const Duration(milliseconds: 300), () {
      provider.addBotMessage(suggestion.fullResponse!);
      _scrollToBottom();
    });

    // Hide suggestions after use
    setState(() {
      _showSuggestions = false;
      _showWelcome = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kajima AI',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Game Consultant',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Toggle suggestions button
          IconButton(
            icon: Icon(
              _showSuggestions ? Icons.lightbulb : Icons.lightbulb_outline,
            ),
            onPressed: () {
              setState(() {
                _showSuggestions = !_showSuggestions;
              });
            },
            tooltip: _showSuggestions ? 'Ẩn gợi ý' : 'Hiện gợi ý',
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => _startNewChat(),
            tooltip: 'Trò chuyện mới',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showChatHistory(),
            tooltip: 'Lịch sử chat',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearDialog(),
            tooltip: 'Xóa lịch sử',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick action buttons
          Consumer<ChatbotProvider>(
            builder: (context, provider, child) {
              return QuickActionButtons(
                onActionTap: (action) {
                  provider.sendQuickAction(action);
                  _scrollToBottom();
                  setState(() {
                    _showSuggestions = false;
                  });
                },
              );
            },
          ),

          const Divider(height: 1),

          // Suggestion chips row (scrollable)
          if (_showSuggestions) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Gợi ý câu hỏi:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SuggestionsRow(
                    suggestions: ChatSuggestionsService.getMainSuggestions(),
                    onSuggestionTapped: _handleSuggestionTap,
                    selectedId: _selectedSuggestionCategory,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Messages list
          Expanded(
            child: Consumer<ChatbotProvider>(
              builder: (context, provider, child) {
                // Show empty state or welcome message
                if (!provider.hasMessages && !_showWelcome) {
                  return _buildEmptyState();
                }

                // Build messages list
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount:
                      (_showWelcome ? 1 : 0) +
                      provider.messages.length +
                      (provider.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Welcome message
                    if (_showWelcome && index == 0) {
                      return ChatBubbleBot(
                        message: provider.getWelcomeMessage(),
                      );
                    }

                    // Adjust index if welcome shown
                    final adjustedIndex = _showWelcome ? index - 1 : index;

                    // Typing indicator
                    if (adjustedIndex == provider.messages.length) {
                      return const TypingIndicator();
                    }

                    // Regular messages
                    final message = provider.messages[adjustedIndex];

                    if (message.isUserMessage) {
                      return ChatBubbleUser(message: message);
                    } else {
                      return ChatBubbleBot(message: message);
                    }
                  },
                );
              },
            ),
          ),

          // Input field
          Consumer<ChatbotProvider>(
            builder: (context, provider, child) {
              return ChatInputField(
                onSendText: (text) {
                  provider.sendTextMessage(text);
                  _scrollToBottom();
                  setState(() {
                    _showSuggestions = false;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.secondary.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chào mừng đến với Kajima AI! 🎮',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tôi là trợ lý game thông minh của bạn. Hỏi tôi về game, thống kê, achievements, hoặc bất cứ điều gì!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Featured suggestions
          Text(
            '💡 Câu hỏi phổ biến:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Main category cards
          ...ChatSuggestionsService.getMainSuggestions().map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SuggestionCard(
                suggestion: suggestion,
                onTap: () => _handleSuggestionTap(suggestion),
              ),
            );
          }).toList(),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 8),
              Text(
                'Chạm vào để khám phá',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử chat?'),
        content: const Text(
          'Bạn có chắc muốn xóa toàn bộ lịch sử trò chuyện? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatbotProvider>().clearHistory();
              Navigator.pop(context);
              setState(() {
                _showWelcome = true;
              });
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _startNewChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🆕 Trò chuyện mới'),
        content: const Text(
          'Bạn có muốn bắt đầu cuộc trò chuyện mới? Lịch sử hiện tại sẽ được lưu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // Don't clear history, just scroll to bottom and show welcome
              Navigator.pop(context);
              setState(() {
                _showWelcome = true;
              });
              _scrollToBottom();
            },
            child: const Text('Bắt đầu'),
          ),
        ],
      ),
    );
  }

  void _showChatHistory() {
    final provider = context.read<ChatbotProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Lịch sử chat (${provider.messageCount} tin nhắn)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Messages list
              Expanded(
                child: provider.messages.isEmpty
                    ? const Center(child: Text('Chưa có lịch sử chat'))
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];
                          final isUser = message.isUserMessage;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1)
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isUser ? Icons.person : Icons.smart_toy,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isUser ? 'Bạn' : 'Kajima AI',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatTime(message.timestamp),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  message.message ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} giờ trước';
    } else {
      return '${diff.inDays} ngày trước';
    }
  }
}

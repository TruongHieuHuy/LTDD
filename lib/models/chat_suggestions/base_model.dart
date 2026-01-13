/// Base model for chat suggestion items
class ChatSuggestion {
  final String id;
  final String title;
  final String icon;
  final String? description;
  final List<ChatSuggestion>? subItems;
  final String? fullResponse;

  ChatSuggestion({
    required this.id,
    required this.title,
    required this.icon,
    this.description,
    this.subItems,
    this.fullResponse,
  });

  bool get hasSubItems => subItems != null && subItems!.isNotEmpty;
}

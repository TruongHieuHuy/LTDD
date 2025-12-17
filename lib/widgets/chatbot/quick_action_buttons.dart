import 'package:flutter/material.dart';

class QuickActionButtons extends StatelessWidget {
  final Function(String) onActionTap;

  const QuickActionButtons({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Quick Actions (Trả lời ngay - không chờ)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionChip(
                  context,
                  emoji: '🎲',
                  label: 'Đoán Số',
                  action: 'rules_guess',
                  color: Colors.blue,
                ),
                _buildActionChip(
                  context,
                  emoji: '🐮',
                  label: 'Bò & Bê',
                  action: 'rules_cowsbulls',
                  color: Colors.orange,
                ),
                _buildActionChip(
                  context,
                  emoji: '🧩',
                  label: 'Memory Match',
                  action: 'rules_memory',
                  color: Colors.purple,
                ),
                _buildActionChip(
                  context,
                  emoji: '⚡',
                  label: 'Quick Math',
                  action: 'rules_quickmath',
                  color: Colors.red,
                ),
                _buildActionChip(
                  context,
                  emoji: '🤖',
                  label: 'AI Chat',
                  action: 'about_ai',
                  color: Colors.teal,
                ),
                _buildActionChip(
                  context,
                  emoji: '💬',
                  label: 'P2P Chat',
                  action: 'about_p2p',
                  color: Colors.indigo,
                ),
                _buildActionChip(
                  context,
                  emoji: '📊',
                  label: 'Stats',
                  action: 'my_stats',
                  color: Colors.green,
                ),
                _buildActionChip(
                  context,
                  emoji: '💡',
                  label: 'Tips',
                  action: 'tips',
                  color: Colors.amber,
                ),
                _buildActionChip(
                  context,
                  emoji: '🏆',
                  label: 'Huy hiệu',
                  action: 'achievements',
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required String emoji,
    required String label,
    required String action,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onActionTap(action),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

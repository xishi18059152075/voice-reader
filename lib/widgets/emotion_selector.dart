import 'package:flutter/material.dart';
import '../models/reading_state.dart';

/// 情绪选择器组件
class EmotionSelector extends StatelessWidget {
  final EmotionStyle currentEmotion;
  final ValueChanged<EmotionStyle> onChanged;

  const EmotionSelector({
    super.key,
    required this.currentEmotion,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '朗读情感',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: EmotionStyle.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final emotion = EmotionStyle.values[index];
              final isSelected = emotion == currentEmotion;
              return GestureDetector(
                onTap: () => onChanged(emotion),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _emotionIcon(emotion),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        emotion.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _emotionIcon(EmotionStyle emotion) {
    switch (emotion) {
      case EmotionStyle.calm:
        return '😌';
      case EmotionStyle.cheerful:
        return '😊';
      case EmotionStyle.sad:
        return '😢';
      case EmotionStyle.angry:
        return '😠';
      case EmotionStyle.fearful:
        return '😨';
      case EmotionStyle.comfort:
        return '🤗';
      case EmotionStyle.serious:
        return '🧐';
      case EmotionStyle.empathy:
        return '💛';
    }
  }
}

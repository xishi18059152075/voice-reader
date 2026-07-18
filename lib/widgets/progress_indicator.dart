import 'package:flutter/material.dart';

/// 朗读进度指示器
class ProgressIndicatorBar extends StatelessWidget {
  final int currentParagraph;
  final int totalParagraphs;

  const ProgressIndicatorBar({
    super.key,
    required this.currentParagraph,
    required this.totalParagraphs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalParagraphs > 0 ? currentParagraph / totalParagraphs : 0.0;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '段落 $currentParagraph / $totalParagraphs',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

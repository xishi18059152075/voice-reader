import 'package:flutter/material.dart';

/// 文件卡片组件
class FileCard extends StatelessWidget {
  final String fileName;
  final int? paragraphCount;
  final int? totalPages;
  final bool hasProgress;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FileCard({
    super.key,
    required this.fileName,
    this.paragraphCount,
    this.totalPages,
    this.hasProgress = false,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final icon = isPdf ? Icons.picture_as_pdf : Icons.description;
    final color = isPdf ? Colors.redAccent : theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: paragraphCount != null
            ? Text(
                '$paragraphCount 段落${totalPages != null ? ' · $totalPages 页' : ''}${hasProgress ? ' · 继续阅读' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasProgress)
              Icon(Icons.play_circle_fill,
                  color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.close, size: 18,
                  color: theme.colorScheme.onSurfaceVariant),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

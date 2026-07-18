import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/file_provider.dart';
import '../widgets/file_card.dart';

/// 文件列表首页
class FileListScreen extends ConsumerWidget {
  const FileListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileState = ref.watch(fileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('语音朗读助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: '设置',
          ),
        ],
      ),
      body: Column(
        children: [
          // 标题区
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择文档',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '支持 PDF 和 Word 文档，AI 情感朗读',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // 最近文件列表
          Expanded(
            child: fileState.recentFiles.isEmpty
                ? _buildEmptyState(context, theme)
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: fileState.recentFiles.length,
                    itemBuilder: (context, index) {
                      final filePath = fileState.recentFiles[index];
                      final fileName = filePath.split('\\').last.split('/').last;
                      return FileCard(
                        fileName: fileName,
                        onTap: () async {
                          await ref
                              .read(fileProvider.notifier)
                              .openFile(filePath);
                          if (ref.read(fileProvider).currentDocument != null) {
                            if (context.mounted) {
                              Navigator.pushNamed(context, '/reader');
                            }
                          }
                        },
                        onDelete: () {
                          // 从最近列表移除
                          final files =
                              List<String>.from(fileState.recentFiles);
                          files.removeAt(index);
                          // 实际应用中应持久化
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      // 底部选择文件按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await ref.read(fileProvider.notifier).pickFile();
          if (ref.read(fileProvider).currentDocument != null) {
            if (context.mounted) {
              Navigator.pushNamed(context, '/reader');
            }
          }
        },
        icon: const Icon(Icons.file_open_outlined),
        label: const Text('选择文件'),
      ),
      // 错误提示
      bottomSheet: fileState.error != null
          ? Container(
              color: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileState.error!,
                      style: TextStyle(
                          color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: theme.colorScheme.onErrorContainer),
                    onPressed: () =>
                        ref.read(fileProvider.notifier).clearError(),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              '还没有打开过文档',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方按钮选择 PDF 或 Word 文件开始朗读',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

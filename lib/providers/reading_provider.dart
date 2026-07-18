import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document_model.dart';
import '../models/reading_state.dart';
import '../services/storage_service.dart';
import 'tts_provider.dart';

/// 阅读状态管理
class ReadingProvider extends StateNotifier<ReadingProgress?> {
  final Ref _ref;
  final StorageService _storage = StorageService();

  ReadingProvider(this._ref) : super(null);

  /// 开始阅读文档
  Future<void> startReading(DocumentModel document, {int startIndex = 0}) async {
    // 先停止之前的朗读
    _ref.read(ttsProvider.notifier).stop();

    // 检查是否有保存进度
    final savedProgress = await _storage.getProgress(document.filePath);
    final startPara = savedProgress?.paragraphIndex ?? startIndex;

    final progress = ReadingProgress(
      filePath: document.filePath,
      paragraphIndex: startPara,
      playbackSpeed: savedProgress?.playbackSpeed ?? 1.0,
      emotionStyle: savedProgress?.emotionStyle ?? 'calm',
      voiceName: savedProgress?.voiceName ?? 'zh-CN-XiaoxiaoNeural',
      lastReadAt: DateTime.now(),
    );

    state = progress;

    // 从指定段落开始朗读
    await _speakParagraph(document, startPara);
  }

  /// 朗读指定段落
  Future<void> _speakParagraph(DocumentModel document, int index) async {
    if (index < 0 || index >= document.paragraphs.length) return;

    final tts = _ref.read(ttsProvider.notifier);
    final paragraph = document.paragraphs[index];

    if (paragraph.isEmpty) {
      // 跳过空段落
      if (index + 1 < document.paragraphs.length) {
        await nextParagraph(document);
      }
      return;
    }

    tts.seekToParagraph(index);
    state = state?.copyWith(
      paragraphIndex: index,
      lastReadAt: DateTime.now(),
    ) as ReadingProgress;

    try {
      await tts.speak(paragraph.text);
      // 保存进度
      if (state != null) {
        await _storage.saveProgress(state!);
      }
    } catch (e) {
      // 朗读失败时静默处理
    }
  }

  /// 下一段
  Future<void> nextParagraph(DocumentModel document) async {
    if (state == null) return;
    final nextIndex = state!.paragraphIndex + 1;
    if (nextIndex < document.paragraphs.length) {
      await _speakParagraph(document, nextIndex);
    }
  }

  /// 上一段
  Future<void> prevParagraph(DocumentModel document) async {
    if (state == null) return;
    final prevIndex = state!.paragraphIndex - 1;
    if (prevIndex >= 0) {
      await _speakParagraph(document, prevIndex);
    }
  }

  /// 跳转到段落
  Future<void> seekToParagraph(DocumentModel document, int index) async {
    if (index >= 0 && index < document.paragraphs.length) {
      await _speakParagraph(document, index);
    }
  }

  /// 暂停
  void pause() => _ref.read(ttsProvider.notifier).pause();

  /// 恢复
  void resume() => _ref.read(ttsProvider.notifier).resume();

  /// 停止
  void stop() {
    _ref.read(ttsProvider.notifier).stop();
    state = null;
  }

  /// 清除阅读状态
  void clear() {
    state = null;
  }

  /// 获取指定文件的进度
  Future<ReadingProgress?> loadProgress(String filePath) async {
    return await _storage.getProgress(filePath);
  }
}

final readingProvider =
    StateNotifierProvider<ReadingProvider, ReadingProgress?>((ref) {
  return ReadingProvider(ref);
});

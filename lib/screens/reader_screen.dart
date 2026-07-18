import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../models/document_model.dart';
import '../models/reading_state.dart';
import '../providers/file_provider.dart';
import '../providers/reading_provider.dart';
import '../providers/tts_provider.dart';
import '../widgets/control_panel.dart';
import '../widgets/emotion_selector.dart';
import '../widgets/progress_indicator.dart';

/// 闃呰鍣ㄩ〉闈?class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _paragraphSub;

  @override
  void dispose() {
    _paragraphSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileState = ref.watch(fileProvider);
    final ttsService = ref.watch(ttsProvider);
    final readingProgress = ref.watch(readingProvider);
    final document = fileState.currentDocument;
    final theme = Theme.of(context);

    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('闃呰鍣?)),
        body: const Center(child: Text('娌℃湁鎵撳紑鏂囨。')),
      );
    }

    // 鑾峰彇褰撳墠鏈楄鐨勬钀界储寮?    final currentParaIndex = readingProgress?.paragraphIndex ?? 0;
    final isPlaying = ttsService.isPlaying;
    final isPaused = ttsService.isPaused;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          document.displayName,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => _showSettingsDialog(context, document),
            tooltip: '鏈楄璁剧疆',
          ),
        ],
      ),
      body: Column(
        children: [
          // 杩涘害鏉?          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProgressIndicatorBar(
              currentParagraph: currentParaIndex + 1,
              totalParagraphs: document.paragraphCount,
            ),
          ),
          // 鏂囨湰鍐呭
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: document.paragraphs.length,
              itemBuilder: (context, index) {
                final paragraph = document.paragraphs[index];
                final isCurrent = index == currentParaIndex;

                return GestureDetector(
                  onTap: () {
                    ref.read(readingProvider.notifier).seekToParagraph(
                          document,
                          index,
                        );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.4)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrent
                          ? Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.5),
                            )
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 娈佃惤缂栧彿
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        // 娈佃惤鏂囨湰
                        Expanded(
                          child: Text(
                            paragraph.text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              fontSize: isCurrent ? 16 : 15,
                              fontWeight: isCurrent
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 搴曢儴鎺у埗闈㈡澘
          ControlPanel(
            playbackState: ttsService.state,
            speed: ttsService.currentSpeed,
            onPlay: () {
              ref
                  .read(readingProvider.notifier)
                  .startReading(document);
            },
            onPause: () {
              ref.read(readingProvider.notifier).pause();
            },
            onResume: () {
              ref.read(readingProvider.notifier).resume();
            },
            onStop: () {
              ref.read(readingProvider.notifier).stop();
            },
            onPrev: () {
              ref.read(readingProvider.notifier).prevParagraph(document);
            },
            onNext: () {
              ref.read(readingProvider.notifier).nextParagraph(document);
            },
            onSpeedChanged: (speed) {
              ref.read(ttsProvider.notifier).setSpeed(speed);
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, DocumentModel document) {
    final tts = ref.read(ttsProvider.notifier);
    final currentEmotion = tts.currentEmotion;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        String selectedVoice = tts.currentVoice;
        EmotionStyle selectedEmotion = currentEmotion;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '鏈楄璁剧疆',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  // 澹伴煶閫夋嫨
                  Text('閫夋嫨澹伴煶',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedVoice,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: AppConfig.chineseVoices
                        .map((v) => DropdownMenuItem(
                              value: v['name'],
                              child: Text(v['label']!),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setSheetState(() => selectedVoice = v);
                        tts.setVoice(v);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // 鎯呯华閫夋嫨
                  EmotionSelector(
                    currentEmotion: selectedEmotion,
                    onChanged: (emotion) {
                      setSheetState(() => selectedEmotion = emotion);
                      tts.setEmotion(emotion);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('纭畾'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

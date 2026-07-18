import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_state.dart';
import '../services/tts_service.dart';

/// TTS 鐘舵€佺鐞?class TtsProvider extends StateNotifier<TtsService> {
  TtsProvider() : super(TtsService());

  /// 閰嶇疆 Azure
  void configure(String key, String region) {
    state.configure(key, region);
  }

  /// 鎾斁鏂囨湰
  Future<void> speak(String text) async {
    try {
      await state.speak(text);
    } catch (e) {
      rethrow;
    }
  }

  /// 鏆傚仠
  void pause() => state.pause();

  /// 鎭㈠
  void resume() => state.resume();

  /// 鍋滄
  void stop() => state.stop();

  /// 璁剧疆璇€?  void setSpeed(double speed) => state.setSpeed(speed);

  /// 璁剧疆澹伴煶
  void setVoice(String voice) => state.setVoice(voice);

  /// 璁剧疆鎯呯华
  void setEmotion(EmotionStyle emotion) => state.setEmotion(emotion);

  /// 鑾峰彇褰撳墠鎯呯华
  EmotionStyle get currentEmotion => state.currentEmotion;

  /// 鑾峰彇褰撳墠澹伴煶
  String get currentVoice => state.currentVoice;

  /// 鑾峰彇褰撳墠璇€?  double get currentSpeed => state.currentSpeed;

  /// 璺宠浆鍒版钀?  void seekToParagraph(int index) => state.seekToParagraph(index);

  /// 鏄惁姝ｅ湪鎾斁
  bool get isPlaying => state.isPlaying;

  /// 鏄惁宸叉殏鍋?  bool get isPaused => state.isPaused;

  /// 鏄惁宸插仠姝?  bool get isStopped => state.state == PlaybackState.stopped;

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}

final ttsProvider = StateNotifierProvider<TtsProvider, TtsService>((ref) {
  return TtsProvider();
});

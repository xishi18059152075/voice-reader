import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_state.dart';
import '../services/tts_service.dart';

/// TTS 状态管理
class TtsProvider extends StateNotifier<TtsService> {
  TtsProvider() : super(TtsService());

  /// 配置 Azure
  void configure(String key, String region) {
    state.configure(key, region);
  }

  /// 播放文本
  Future<void> speak(String text) async {
    try {
      await state.speak(text);
    } catch (e) {
      rethrow;
    }
  }

  /// 暂停
  void pause() => state.pause();

  /// 恢复
  void resume() => state.resume();

  /// 停止
  void stop() => state.stop();

  /// 设置语速
  void setSpeed(double speed) => state.setSpeed(speed);

  /// 设置声音
  void setVoice(String voice) => state.setVoice(voice);

  /// 设置情绪
  void setEmotion(EmotionStyle emotion) => state.setEmotion(emotion);

  /// 获取当前情绪
  EmotionStyle get currentEmotion => state.currentEmotion;

  /// 获取当前声音
  String get currentVoice => state.currentVoice;

  /// 获取当前语速
  double get currentSpeed => state.currentSpeed;

  /// 跳转到段落
  void seekToParagraph(int index) => state.seekToParagraph(index);

  /// 是否正在播放
  bool get isPlaying => state.isPlaying;

  /// 是否已暂停
  bool get isPaused => state.isPaused;

  /// 是否已停止
  bool get isStopped => state.state == PlaybackState.stopped;

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}

final ttsProvider = StateNotifierProvider<TtsProvider, TtsService>((ref) {
  return TtsProvider();
});

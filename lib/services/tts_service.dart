import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';
import '../models/reading_state.dart';

/// Azure TTS 情感语音合成服务
class TtsService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  // TTS 状态
  PlaybackState _state = PlaybackState.stopped;
  double _currentSpeed = 1.0;
  String _currentVoice = AppConfig.defaultVoice;
  EmotionStyle _currentEmotion = EmotionStyle.calm;
  int _currentParagraphIndex = 0;
  String? _azureKey;
  String _azureRegion = AppConfig.azureRegion;

  // 回调
  void Function(int paragraphIndex)? onParagraphChanged;
  void Function(PlaybackState state)? onStateChanged;

  // Getters
  PlaybackState get state => _state;
  double get currentSpeed => _currentSpeed;
  String get currentVoice => _currentVoice;
  EmotionStyle get currentEmotion => _currentEmotion;
  int get currentParagraphIndex => _currentParagraphIndex;
  AudioPlayer get player => _player;
  bool get isPlaying => _state == PlaybackState.playing;
  bool get isPaused => _state == PlaybackState.paused;
  bool get isConfigured => _azureKey != null && _azureKey!.isNotEmpty;

  TtsService() {
    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed &&
          _player.playing == false) {
        _setState(PlaybackState.stopped);
      }
    });
  }

  void _setState(PlaybackState newState) {
    _state = newState;
    onStateChanged?.call(newState);
    notifyListeners();
  }

  /// 配置 Azure TTS
  void configure(String key, String region) {
    _azureKey = key;
    _azureRegion = region;
    notifyListeners();
  }

  /// 设置语速
  void setSpeed(double speed) {
    _currentSpeed = speed.clamp(0.5, 2.0);
    _player.setSpeed(_currentSpeed);
    notifyListeners();
  }

  /// 设置声音
  void setVoice(String voiceName) {
    _currentVoice = voiceName;
    notifyListeners();
  }

  /// 设置情绪风格
  void setEmotion(EmotionStyle emotion) {
    _currentEmotion = emotion;
    notifyListeners();
  }

  /// 获取 Azure TTS 访问令牌
  Future<String> _getAccessToken() async {
    final url = Uri.parse(
        'https://$_azureRegion.api.cognitive.microsoft.com/sts/v1.0/issueToken');
    final response = await http.post(
      url,
      headers: {'Ocp-Apim-Subscription-Key': _azureKey!},
    );

    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception('Azure 令牌获取失败: ${response.statusCode}');
  }

  /// 构建情感 SSML
  String _buildEmotionalSsml(String text, {EmotionStyle? overrideEmotion}) {
    final emotion = overrideEmotion ?? _currentEmotion;
    final escapedText = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');

    return '''<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
      xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="zh-CN">
      <voice name="$_currentVoice">
        <mstts:express-as style="${emotion.apiValue}" styledegree="1.5">
          <prosody rate="${_currentSpeed.toStringAsFixed(1)}">
            $escapedText
          </prosody>
        </mstts:express-as>
      </voice>
    </speak>''';
  }

  /// 调用 TTS API 合成语音
  Future<Uint8List> _synthesizeSpeech(String ssml, String accessToken) async {
    final url = Uri.parse(
        'https://$_azureRegion.tts.speech.microsoft.com/cognitiveservices/v1');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/ssml+xml',
        'X-Microsoft-OutputFormat': 'audio-24khz-48kbitrate-mono-mp3',
      },
      body: ssml,
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('语音合成失败: ${response.statusCode}');
  }

  /// 合成并播放文本
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    if (!isConfigured) {
      throw Exception('请先在设置中配置 Azure API Key');
    }

    _setState(PlaybackState.loading);

    try {
      final accessToken = await _getAccessToken();
      final ssml = _buildEmotionalSsml(text);
      final audioBytes = await _synthesizeSpeech(ssml, accessToken);

      // 写入临时文件
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await tempFile.writeAsBytes(audioBytes);

      // 播放
      await _player.setAudioSource(AudioSource.file(tempFile.path));
      _player.setSpeed(_currentSpeed);
      _player.play();
      _setState(PlaybackState.playing);
    } catch (e) {
      _setState(PlaybackState.stopped);
      rethrow;
    }
  }

  /// 暂停
  void pause() {
    _player.pause();
    _setState(PlaybackState.paused);
  }

  /// 恢复
  void resume() {
    _player.play();
    _setState(PlaybackState.playing);
  }

  /// 停止
  void stop() {
    _player.stop();
    _setState(PlaybackState.stopped);
  }

  /// 跳转到指定段落
  void seekToParagraph(int index) {
    _currentParagraphIndex = index;
    onParagraphChanged?.call(index);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

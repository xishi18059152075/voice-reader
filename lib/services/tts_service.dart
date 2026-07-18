import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';
import '../models/reading_state.dart';

/// Azure TTS 鎯呮劅璇煶鍚堟垚鏈嶅姟
class TtsService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  // TTS 鐘舵€?  PlaybackState _state = PlaybackState.stopped;
  double _currentSpeed = 1.0;
  String _currentVoice = AppConfig.defaultVoice;
  EmotionStyle _currentEmotion = EmotionStyle.calm;
  int _currentParagraphIndex = 0;
  String? _azureKey;
  String _azureRegion = AppConfig.azureRegion;

  // 鍥炶皟
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

  /// 閰嶇疆 Azure TTS
  void configure(String key, String region) {
    _azureKey = key;
    _azureRegion = region;
    notifyListeners();
  }

  /// 璁剧疆璇€?  void setSpeed(double speed) {
    _currentSpeed = speed.clamp(0.5, 2.0);
    _player.setSpeed(_currentSpeed);
    notifyListeners();
  }

  /// 璁剧疆澹伴煶
  void setVoice(String voiceName) {
    _currentVoice = voiceName;
    notifyListeners();
  }

  /// 璁剧疆鎯呯华椋庢牸
  void setEmotion(EmotionStyle emotion) {
    _currentEmotion = emotion;
    notifyListeners();
  }

  /// 鑾峰彇 Azure TTS 璁块棶浠ょ墝
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
    throw Exception('Azure 浠ょ墝鑾峰彇澶辫触: ${response.statusCode}');
  }

  /// 鏋勫缓鎯呮劅 SSML
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

  /// 璋冪敤 TTS API 鍚堟垚璇煶
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
    throw Exception('璇煶鍚堟垚澶辫触: ${response.statusCode}');
  }

  /// 鍚堟垚骞舵挱鏀炬枃鏈?  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    if (!isConfigured) {
      throw Exception('璇峰厛鍦ㄨ缃腑閰嶇疆 Azure API Key');
    }

    _setState(PlaybackState.loading);

    try {
      final accessToken = await _getAccessToken();
      final ssml = _buildEmotionalSsml(text);
      final audioBytes = await _synthesizeSpeech(ssml, accessToken);

      // 鍐欏叆涓存椂鏂囦欢
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await tempFile.writeAsBytes(audioBytes);

      // 鎾斁
      await _player.setAudioSource(AudioSource.file(tempFile.path));
      _player.setSpeed(_currentSpeed);
      _player.play();
      _setState(PlaybackState.playing);
    } catch (e) {
      _setState(PlaybackState.stopped);
      rethrow;
    }
  }

  /// 鏆傚仠
  void pause() {
    _player.pause();
    _setState(PlaybackState.paused);
  }

  /// 鎭㈠
  void resume() {
    _player.play();
    _setState(PlaybackState.playing);
  }

  /// 鍋滄
  void stop() {
    _player.stop();
    _setState(PlaybackState.stopped);
  }

  /// 璺宠浆鍒版寚瀹氭钀?  void seekToParagraph(int index) {
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

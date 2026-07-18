import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_state.dart';

/// 本地持久化服务 - 保存阅读进度和应用设置
class StorageService {
  static const String _recentFilesKey = 'recent_files';
  static const String _progressPrefix = 'progress_';
  static const String _azureKeyKey = 'azure_api_key';
  static const String _azureRegionKey = 'azure_region';
  static const String _defaultVoiceKey = 'default_voice';
  static const String _defaultEmotionKey = 'default_emotion';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // === 最近文件列表 ===
  Future<List<String>> getRecentFiles() async {
    final p = await prefs;
    return p.getStringList(_recentFilesKey) ?? [];
  }

  Future<void> addRecentFile(String filePath) async {
    final p = await prefs;
    final files = await getRecentFiles();
    files.remove(filePath); // 去重
    files.insert(0, filePath); // 插入到最前
    // 只保留最近 20 个文件
    await p.setStringList(
        _recentFilesKey, files.take(20).toList());
  }

  // === 阅读进度 ===
  Future<void> saveProgress(ReadingProgress progress) async {
    final p = await prefs;
    final key = '$_progressPrefix${progress.filePath}';
    await p.setString(key, jsonEncode(progress.toJson()));
  }

  Future<ReadingProgress?> getProgress(String filePath) async {
    final p = await prefs;
    final key = '$_progressPrefix$filePath';
    final json = p.getString(key);
    if (json == null) return null;
    try {
      return ReadingProgress.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // === Azure TTS 配置 ===
  Future<void> setAzureKey(String key) async {
    final p = await prefs;
    await p.setString(_azureKeyKey, key);
  }

  Future<String?> getAzureKey() async {
    final p = await prefs;
    return p.getString(_azureKeyKey);
  }

  Future<void> setAzureRegion(String region) async {
    final p = await prefs;
    await p.setString(_azureRegionKey, region);
  }

  Future<String?> getAzureRegion() async {
    final p = await prefs;
    return p.getString(_azureRegionKey);
  }

  // === 默认设置 ===
  Future<void> setDefaultVoice(String voice) async {
    final p = await prefs;
    await p.setString(_defaultVoiceKey, voice);
  }

  Future<String> getDefaultVoice() async {
    final p = await prefs;
    return p.getString(_defaultVoiceKey) ?? 'zh-CN-XiaoxiaoNeural';
  }

  Future<void> setDefaultEmotion(String emotion) async {
    final p = await prefs;
    await p.setString(_defaultEmotionKey, emotion);
  }

  Future<String> getDefaultEmotion() async {
    final p = await prefs;
    return p.getString(_defaultEmotionKey) ?? 'calm';
  }
}

/// 应用配置
class AppConfig {
  // Azure 语音服务配置
  static const String azureRegion = 'eastasia';
  static const String defaultVoice = 'zh-CN-XiaoxiaoNeural';
  static const String defaultEmotion = 'calm';

  // 支持的语音列表（中文）
  static const List<Map<String, String>> chineseVoices = [
    {'name': 'zh-CN-XiaoxiaoNeural', 'label': '晓晓（女声）'},
    {'name': 'zh-CN-XiaoyiNeural', 'label': '晓依（女声）'},
    {'name': 'zh-CN-YunxiNeural', 'label': '云希（男声）'},
    {'name': 'zh-CN-YunyeNeural', 'label': '云扬（男声）'},
    {'name': 'zh-CN-YunyangNeural', 'label': '云阳（男声）'},
  ];

  // 支持的中英混合情感声音
  static const List<Map<String, String>> bilingualVoices = [
    {'name': 'zh-CN-XiaoxiaoNeural', 'label': '晓晓（中英混合）'},
    {'name': 'zh-CN-YunxiNeural', 'label': '云希（中英混合）'},
  ];

  // 语速范围
  static const double minSpeed = 0.5;
  static const double maxSpeed = 2.0;
  static const double defaultSpeed = 1.0;

  // 应用名称
  static const String appName = '语音朗读助手';
  static const String appVersion = '1.0.0';
}

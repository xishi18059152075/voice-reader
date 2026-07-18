/// 朗读状态枚举
enum PlaybackState {
  stopped,
  playing,
  paused,
  loading,
}

/// 情感风格枚举
enum EmotionStyle {
  calm('平静', 'calm', '适合叙述、说明类文章'),
  cheerful('愉快', 'cheerful', '适合正面内容、故事'),
  sad('悲伤', 'sad', '适合感伤内容'),
  angry('愤怒', 'angry', '适合激烈内容'),
  fearful('害怕', 'fearful', '适合悬疑内容'),
  comfort('安慰', 'comfort', '适合温馨内容'),
  serious('严肃', 'serious', '适合正式内容'),
  empathy('共情', 'empathy', '适合情感内容');

  final String label;
  final String apiValue;
  final String description;

  const EmotionStyle(this.label, this.apiValue, this.description);
}

/// 朗读进度
class ReadingProgress {
  final String filePath;
  final int paragraphIndex;
  final int positionInParagraph;
  final double playbackSpeed;
  final String emotionStyle;
  final String voiceName;
  final DateTime lastReadAt;

  const ReadingProgress({
    required this.filePath,
    required this.paragraphIndex,
    this.positionInParagraph = 0,
    this.playbackSpeed = 1.0,
    this.emotionStyle = 'calm',
    this.voiceName = 'zh-CN-XiaoxiaoNeural',
    required this.lastReadAt,
  });

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'paragraphIndex': paragraphIndex,
        'positionInParagraph': positionInParagraph,
        'playbackSpeed': playbackSpeed,
        'emotionStyle': emotionStyle,
        'voiceName': voiceName,
        'lastReadAt': lastReadAt.toIso8601String(),
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      ReadingProgress(
        filePath: json['filePath'] as String,
        paragraphIndex: json['paragraphIndex'] as int,
        positionInParagraph: json['positionInParagraph'] as int? ?? 0,
        playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
        emotionStyle: json['emotionStyle'] as String? ?? 'calm',
        voiceName: json['voiceName'] as String? ?? 'zh-CN-XiaoxiaoNeural',
        lastReadAt: DateTime.parse(json['lastReadAt'] as String),
      );
}

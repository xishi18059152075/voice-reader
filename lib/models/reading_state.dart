/// 鏈楄鐘舵€佹灇涓?enum PlaybackState {
  stopped,
  playing,
  paused,
  loading,
}

/// 鎯呮劅椋庢牸鏋氫妇
enum EmotionStyle {
  calm('骞抽潤', 'calm', '閫傚悎鍙欒堪銆佽鏄庣被鏂囩珷'),
  cheerful('鎰夊揩', 'cheerful', '閫傚悎姝ｉ潰鍐呭銆佹晠浜?),
  sad('鎮蹭激', 'sad', '閫傚悎鎰熶激鍐呭'),
  angry('鎰ゆ€?, 'angry', '閫傚悎婵€鐑堝唴瀹?),
  fearful('瀹虫€?, 'fearful', '閫傚悎鎮枒鍐呭'),
  comfort('瀹夋叞', 'comfort', '閫傚悎娓╅Θ鍐呭'),
  serious('涓ヨ們', 'serious', '閫傚悎姝ｅ紡鍐呭'),
  empathy('鍏辨儏', 'empathy', '閫傚悎鎯呮劅鍐呭');

  final String label;
  final String apiValue;
  final String description;

  const EmotionStyle(this.label, this.apiValue, this.description);
}

/// 鏈楄杩涘害
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

  ReadingProgress copyWith({
    String? filePath,
    int? paragraphIndex,
    int? positionInParagraph,
    double? playbackSpeed,
    String? emotionStyle,
    String? voiceName,
    DateTime? lastReadAt,
  }) {
    return ReadingProgress(
      filePath: filePath ?? this.filePath,
      paragraphIndex: paragraphIndex ?? this.paragraphIndex,
      positionInParagraph: positionInParagraph ?? this.positionInParagraph,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      emotionStyle: emotionStyle ?? this.emotionStyle,
      voiceName: voiceName ?? this.voiceName,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
}

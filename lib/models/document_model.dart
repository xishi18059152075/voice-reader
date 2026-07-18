/// 文件类型枚举
enum FileType {
  pdf,
  word,
  unknown;

  static FileType fromExtension(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.pdf')) return FileType.pdf;
    if (ext.endsWith('.docx') || ext.endsWith('.doc')) return FileType.word;
    return FileType.unknown;
  }
}

/// 段落模型 - 保存文本和位置信息
class Paragraph {
  final String text;
  final int index;
  final int pageNumber;

  const Paragraph({
    required this.text,
    required this.index,
    required this.pageNumber,
  });

  bool get isEmpty => text.trim().isEmpty;

  Map<String, dynamic> toJson() => {
        'text': text,
        'index': index,
        'pageNumber': pageNumber,
      };

  factory Paragraph.fromJson(Map<String, dynamic> json) => Paragraph(
        text: json['text'] as String,
        index: json['index'] as int,
        pageNumber: json['pageNumber'] as int,
      );
}

/// 文档模型
class DocumentModel {
  final String filePath;
  final String fileName;
  final FileType fileType;
  final List<Paragraph> paragraphs;
  final int totalPages;

  const DocumentModel({
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.paragraphs,
    required this.totalPages,
  });

  String get displayName => fileName;

  int get paragraphCount => paragraphs.length;

  List<Paragraph> get nonEmptyParagraphs =>
      paragraphs.where((p) => !p.isEmpty).toList();

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'fileName': fileName,
        'fileType': fileType.name,
        'totalPages': totalPages,
        'paragraphs': paragraphs.map((p) => p.toJson()).toList(),
      };
}

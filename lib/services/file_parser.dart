import '../models/document_model.dart';
import 'pdf_extractor.dart';
import 'docx_extractor.dart';

/// 统一文件解析接口
class FileParser {
  /// 解析文件，返回文档模型
  static Future<DocumentModel> parseFile(String filePath) async {
    final fileName = filePath.split('/').last.split('\\').last;
    final fileType = FileType.fromExtension(filePath);

    List<Paragraph> paragraphs;
    int totalPages = 1;

    switch (fileType) {
      case FileType.pdf:
        paragraphs = await PdfExtractor.extractParagraphs(filePath);
        try {
          totalPages = await PdfExtractor.getPageCount(filePath);
        } catch (_) {
          totalPages = 1;
        }
        break;
      case FileType.word:
        paragraphs = await DocxExtractor.extractParagraphs(filePath);
        break;
      case FileType.unknown:
        throw Exception('不支持的文件格式');
    }

    return DocumentModel(
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
      paragraphs: paragraphs,
      totalPages: totalPages,
    );
  }
}

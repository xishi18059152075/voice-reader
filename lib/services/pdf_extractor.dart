import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/document_model.dart';

/// PDF 文本提取器
class PdfExtractor {
  /// 从 PDF 文件中提取段落文本
  static Future<List<Paragraph>> extractParagraphs(String filePath) async {
    final paragraphs = <Paragraph>[];
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    try {
      final bytes = await file.readAsBytes();
      final pdfDocument = PdfDocument(inputBytes: bytes);
      final pageCount = pdfDocument.pages.count;

      int paragraphIndex = 0;
      for (int page = 0; page < pageCount; page++) {
        final text = PdfTextExtractor(pdfDocument).extractText(
          startPageIndex: page,
          endPageIndex: page,
        );

        // 按换行符分割为段落
        final lines = text.split('\n');
        String currentParagraph = '';
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) {
            if (currentParagraph.isNotEmpty) {
              paragraphs.add(Paragraph(
                text: currentParagraph.trim(),
                index: paragraphIndex++,
                pageNumber: page + 1,
              ));
              currentParagraph = '';
            }
          } else {
            currentParagraph += '$trimmed ';
          }
        }
        if (currentParagraph.isNotEmpty) {
          paragraphs.add(Paragraph(
            text: currentParagraph.trim(),
            index: paragraphIndex++,
            pageNumber: page + 1,
          ));
        }
      }

      pdfDocument.dispose();
      return paragraphs;
    } catch (e) {
      throw Exception('PDF 解析失败: $e');
    }
  }

  /// 获取 PDF 页数
  static Future<int> getPageCount(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final pdfDocument = PdfDocument(inputBytes: bytes);
    final count = pdfDocument.pages.count;
    pdfDocument.dispose();
    return count;
  }
}

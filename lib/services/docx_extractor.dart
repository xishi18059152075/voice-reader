import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '../models/document_model.dart';

/// Word (.docx) 文本提取器
/// .docx 本质是 ZIP 包，包含 word/document.xml
class DocxExtractor {
  /// 从 .docx 文件中提取段落文本
  static Future<List<Paragraph>> extractParagraphs(String filePath) async {
    final paragraphs = <Paragraph>[];
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 查找 word/document.xml
      final documentFile = archive.files.firstWhere(
        (f) => f.name == 'word/document.xml',
        orElse: () => throw Exception('无法解析 .docx 文件结构'),
      );

      final xmlContent = utf8.decode(documentFile.content);
      final document = XmlDocument.parse(xmlContent);

      // 获取所有段落 (w:p)
      final body = document.findAllElements('w:body').first;
      final wPs = body.findElements('w:p');

      int paragraphIndex = 0;
      final allParagraphs = <String>[];

      for (final p in wPs) {
        // 提取段落中的所有文本 (w:t)
        final texts = p
            .findElements('w:r')
            .map((r) => r.findElements('w:t').map((t) => t.innerText).join())
            .join();

        final trimmed = texts.trim();
        if (trimmed.isNotEmpty) {
          allParagraphs.add(trimmed);
        }
      }

      // 对长文本做进一步段落分割（按句号、问号、感叹号等）
      for (final para in allParagraphs) {
        paragraphs.add(Paragraph(
          text: para,
          index: paragraphIndex++,
          pageNumber: 1,
        ));
      }

      return paragraphs;
    } catch (e) {
      throw Exception('Word 文档解析失败: $e');
    }
  }
}

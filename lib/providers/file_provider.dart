import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../models/document_model.dart';
import '../services/file_parser.dart';
import '../services/storage_service.dart';

/// 文件列表状态
class FileListState {
  final List<String> recentFiles;
  final DocumentModel? currentDocument;
  final bool isLoading;
  final String? error;

  const FileListState({
    this.recentFiles = const [],
    this.currentDocument,
    this.isLoading = false,
    this.error,
  });

  FileListState copyWith({
    List<String>? recentFiles,
    DocumentModel? currentDocument,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FileListState(
      recentFiles: recentFiles ?? this.recentFiles,
      currentDocument: currentDocument ?? this.currentDocument,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FileProvider extends StateNotifier<FileListState> {
  final StorageService _storage = StorageService();

  FileProvider() : super(const FileListState()) {
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    final files = await _storage.getRecentFiles();
    // 过滤掉已删除的文件
    final existingFiles = <String>[];
    for (final f in files) {
      if (await File(f).exists()) {
        existingFiles.add(f);
      }
    }
    state = state.copyWith(recentFiles: existingFiles);
  }

  /// 打开文件选择器
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path;
        if (filePath != null) {
          await openFile(filePath);
        }
      }
    } catch (e) {
      state = state.copyWith(error: '文件选择失败: $e');
    }
  }

  /// 打开并解析文件
  Future<void> openFile(String filePath) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final document = await FileParser.parseFile(filePath);
      state = state.copyWith(
        currentDocument: document,
        isLoading: false,
      );
      await _storage.addRecentFile(filePath);
      await _loadRecentFiles();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '文件解析失败: $e',
      );
    }
  }

  /// 清除当前文档
  void closeDocument() {
    state = state.copyWith(currentDocument: null);
  }

  /// 清除错误信息
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final fileProvider = StateNotifierProvider<FileProvider, FileListState>((ref) {
  return FileProvider();
});

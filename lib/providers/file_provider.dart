import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' hide FileType;
import '../models/document_model.dart';
import '../services/file_parser.dart';
import '../services/storage_service.dart';

/// 鏂囦欢鍒楄〃鐘舵€?class FileListState {
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
    // 杩囨护鎺夊凡鍒犻櫎鐨勬枃浠?    final existingFiles = <String>[];
    for (final f in files) {
      if (await File(f).exists()) {
        existingFiles.add(f);
      }
    }
    state = state.copyWith(recentFiles: existingFiles);
  }

  /// 鎵撳紑鏂囦欢閫夋嫨鍣?  Future<void> pickFile() async {
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
      state = state.copyWith(error: '鏂囦欢閫夋嫨澶辫触: $e');
    }
  }

  /// 鎵撳紑骞惰В鏋愭枃浠?  Future<void> openFile(String filePath) async {
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
        error: '鏂囦欢瑙ｆ瀽澶辫触: $e',
      );
    }
  }

  /// 娓呴櫎褰撳墠鏂囨。
  void closeDocument() {
    state = state.copyWith(currentDocument: null);
  }

  /// 娓呴櫎閿欒淇℃伅
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final fileProvider = StateNotifierProvider<FileProvider, FileListState>((ref) {
  return FileProvider();
});

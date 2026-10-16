import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Result returned by the [DocumentDownloadService].
class DownloadResult {
  final bool isSuccess;
  final String? filePath;
  final String? fileName;
  final int fileSizeBytes;
  final String? errorMessage;
  final bool isPdf;
  final bool isAccessibleDownloadsFolder;
  final String displayLocation;

  const DownloadResult({
    required this.isSuccess,
    this.filePath,
    this.fileName,
    this.fileSizeBytes = 0,
    this.errorMessage,
    this.isPdf = false,
    this.isAccessibleDownloadsFolder = false,
    this.displayLocation = '',
  });

  factory DownloadResult.failure(String error) {
    return DownloadResult(
      isSuccess: false,
      errorMessage: error,
    );
  }
}

/// Service for downloading, verifying (%PDF signature), saving to user-accessible
/// storage, and opening/sharing documents.
class DocumentDownloadService {
  static final DocumentDownloadService _instance = DocumentDownloadService._internal();
  factory DocumentDownloadService() => _instance;
  DocumentDownloadService._internal();

  http.Client _client = http.Client();
  Directory? _destinationDirectoryForTesting;

  /// Inject custom client for testing.
  @visibleForTesting
  void setClientForTesting(http.Client client) {
    _client = client;
  }

  /// Inject custom destination directory for testing.
  @visibleForTesting
  void setDestinationDirectoryForTesting(Directory? dir) {
    _destinationDirectoryForTesting = dir;
  }

  /// Resets client and test hooks to standard defaults.
  @visibleForTesting
  void resetClient() {
    _client = http.Client();
    _destinationDirectoryForTesting = null;
  }

  /// Verifies whether the provided byte list starts with the `%PDF` signature (0x25, 0x50, 0x44, 0x46).
  static bool verifyPdfSignature(List<int> bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46; // F
  }

  /// Sanitize filename by removing unsupported characters.
  static String sanitizeFileName(String name) {
    var clean = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (clean.isEmpty) {
      clean = 'camso_document.pdf';
    } else if (!clean.toLowerCase().endsWith('.pdf')) {
      clean = '$clean.pdf';
    }
    return clean;
  }

  /// Resolve destination directory for saving the document.
  /// Prioritizes user-accessible Downloads folder on Android/Desktop.
  Future<({Directory directory, bool isPublicDownloads})> getDestinationDirectory() async {
    if (_destinationDirectoryForTesting != null) {
      return (directory: _destinationDirectoryForTesting!, isPublicDownloads: true);
    }

    // 1. Check direct Android public Downloads path
    if (Platform.isAndroid) {
      try {
        final publicDownloads = Directory('/storage/emulated/0/Download');
        if (publicDownloads.existsSync()) {
          // Verify directory is writable
          final testFile = File('${publicDownloads.path}/.camso_write_test_${DateTime.now().millisecondsSinceEpoch}.tmp');
          try {
            await testFile.writeAsString('test');
            await testFile.delete();
            return (directory: publicDownloads, isPublicDownloads: true);
          } catch (_) {
            // Not writable directly (e.g. Android 11+ scoped storage without MediaStore), continue to next option
          }
        }
      } catch (_) {}

      try {
        final extDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (extDirs != null && extDirs.isNotEmpty) {
          final dir = extDirs.first;
          if (!dir.existsSync()) {
            await dir.create(recursive: true);
          }
          return (directory: dir, isPublicDownloads: true);
        }
      } catch (_) {}
    }

    // 2. Platform downloads directory (Desktop, etc.)
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        if (!downloadsDir.existsSync()) {
          await downloadsDir.create(recursive: true);
        }
        return (directory: downloadsDir, isPublicDownloads: true);
      }
    } catch (_) {}

    // 3. Fallback to app documents directory
    final appDocDir = await getApplicationDocumentsDirectory();
    if (!appDocDir.existsSync()) {
      await appDocDir.create(recursive: true);
    }
    return (directory: appDocDir, isPublicDownloads: false);
  }

  /// Download the PDF binary from [downloadUrl], verify `%PDF` header,
  /// save to disk, and return [DownloadResult].
  Future<DownloadResult> downloadAndSave({
    required String downloadUrl,
    required String preferredFileName,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = Uri.tryParse(downloadUrl);
    if (uri == null) {
      return DownloadResult.failure('Invalid download URL.');
    }

    http.Response response;
    try {
      response = await _client.get(uri, headers: headers).timeout(timeout);
    } on TimeoutException {
      return DownloadResult.failure('Download connection timed out. Please check your internet connection.');
    } on SocketException catch (e) {
      return DownloadResult.failure('Network connection error: ${e.message}');
    } catch (e) {
      return DownloadResult.failure('Failed to download document: $e');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return DownloadResult.failure('Access denied (HTTP ${response.statusCode}). Your session is not authorized to download this document.');
    }

    if (response.statusCode == 404) {
      return DownloadResult.failure('Document file not found on storage server.');
    }

    if (response.statusCode >= 400) {
      return DownloadResult.failure('Storage server returned error (${response.statusCode}). The download link may have expired.');
    }

    final bytes = response.bodyBytes;
    if (bytes.isEmpty) {
      return DownloadResult.failure('Downloaded file is empty (0 bytes received).');
    }

    // Check %PDF magic bytes
    final isPdf = verifyPdfSignature(bytes);
    if (!isPdf) {
      // Check if response body is an XML or JSON error
      final bodyText = String.fromCharCodes(bytes.take(200));
      if (bodyText.contains('<Error>') || bodyText.contains('ExpiredToken') || bodyText.contains('AccessDenied')) {
        return DownloadResult.failure('The download link has expired or is unauthorized. Please try again.');
      }
      return DownloadResult.failure('Downloaded file is corrupt or not a valid PDF document (missing %PDF signature).');
    }

    final cleanName = sanitizeFileName(preferredFileName);

    try {
      final dest = await getDestinationDirectory();
      final targetFile = File('${dest.directory.path}/$cleanName');

      // Atomic write and flush
      targetFile.writeAsBytesSync(bytes, flush: true);

      // Verify file exists on disk and is non-empty
      if (!targetFile.existsSync() || targetFile.lengthSync() == 0) {
        return DownloadResult.failure('Could not confirm file was written to storage.');
      }

      final displayLoc = dest.isPublicDownloads
          ? (dest.directory.path.contains('Download') ? 'Downloads/$cleanName' : targetFile.path)
          : targetFile.path;

      return DownloadResult(
        isSuccess: true,
        filePath: targetFile.path,
        fileName: cleanName,
        fileSizeBytes: bytes.length,
        isPdf: true,
        isAccessibleDownloadsFolder: dest.isPublicDownloads,
        displayLocation: displayLoc,
      );
    } catch (e) {
      return DownloadResult.failure('Could not save file to disk: $e');
    }
  }

  /// Open the downloaded file using the platform file viewer.
  Future<bool> openFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return false;
    }
    try {
      final result = await OpenFilex.open(filePath, type: 'application/pdf');
      return result.type == ResultType.done;
    } catch (_) {
      return false;
    }
  }

  /// Share the downloaded file via system share sheet.
  Future<bool> shareFile(String filePath, {String? text, String? subject}) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return false;
    }
    try {
      final xfile = XFile(filePath, mimeType: 'application/pdf');
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [xfile],
          text: text,
          subject: subject,
        ),
      );
      return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
    } catch (_) {
      return false;
    }
  }
}

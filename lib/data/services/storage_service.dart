import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Local JSON file storage service.
///
/// Implements resilient file persistence with automated fallback for tests and desktop environments.
class StorageService {
  Directory? overrideDir;

  StorageService({this.overrideDir});

  Future<Directory> _getDirectory() async {
    if (overrideDir != null) return overrideDir!;
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      // Fallback for tests or environments where path_provider isn't bound
      final temp = Directory.systemTemp.createTempSync('viking_data_');
      overrideDir = temp;
      return temp;
    }
  }

  Future<File> _getFile(String fileName) async {
    final dir = await _getDirectory();
    return File('${dir.path}/$fileName');
  }

  /// Reads a JSON string from a file, returning null if file does not exist.
  Future<String?> readString(String fileName) async {
    try {
      final file = await _getFile(fileName);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      debugPrint('Error reading $fileName: $e');
    }
    return null;
  }

  /// Writes a JSON string to a file.
  Future<void> writeString(String fileName, String content) async {
    try {
      final file = await _getFile(fileName);
      await file.writeAsString(content, flush: true);
    } catch (e) {
      debugPrint('Error writing to $fileName: $e');
    }
  }

  /// Reads a List of JSON Maps from a file.
  Future<List<Map<String, dynamic>>> readList(String fileName) async {
    final raw = await readString(fileName);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('Error parsing JSON list from $fileName: $e');
    }
    return [];
  }

  /// Writes a List of serializable JSON Maps to a file.
  Future<void> writeList(String fileName, List<Map<String, dynamic>> items) async {
    final encoded = jsonEncode(items);
    await writeString(fileName, encoded);
  }

  /// Exports all Viking data (exercises, workouts, schedules) to a single JSON package.
  Future<String> exportAllData({
    required List<Map<String, dynamic>> exercises,
    required List<Map<String, dynamic>> workouts,
    required List<Map<String, dynamic>> schedules,
  }) async {
    final bundle = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'exercises': exercises,
      'workouts': workouts,
      'schedules': schedules,
    };
    return const JsonEncoder.withIndent('  ').convert(bundle);
  }
}

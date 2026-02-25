import 'dart:typed_data';

/// Stub implementation — should never be reached at runtime.
/// Conditional imports resolve to native or web before this is used.

Future<void> saveAndOpen(String filename, List<int> bytes) =>
    throw UnsupportedError('saveAndOpen is not supported on this platform');

Future<Uint8List?> readFileBytes(String path) =>
    throw UnsupportedError('readFileBytes is not supported on this platform');

Future<void> writeFile(String path, String content) =>
    throw UnsupportedError('writeFile is not supported on this platform');

Future<void> appendToFile(String path, String content) =>
    throw UnsupportedError('appendToFile is not supported on this platform');

Future<void> deleteFile(String path) =>
    throw UnsupportedError('deleteFile is not supported on this platform');

Future<bool> fileExists(String path) =>
    throw UnsupportedError('fileExists is not supported on this platform');

Future<String?> getDocumentsPath() =>
    throw UnsupportedError('getDocumentsPath is not supported on this platform');

bool get hasFileSystem =>
    throw UnsupportedError('hasFileSystem is not supported on this platform');

bool get canExitApp =>
    throw UnsupportedError('canExitApp is not supported on this platform');

void exitApp() =>
    throw UnsupportedError('exitApp is not supported on this platform');

Future<void> deleteDatabaseFiles(String name) =>
    throw UnsupportedError('deleteDatabaseFiles is not supported on this platform');

Future<String?> readDeviceIdFromLegacyFile() =>
    throw UnsupportedError('readDeviceIdFromLegacyFile is not supported on this platform');

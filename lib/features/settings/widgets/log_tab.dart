import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/utils/file_opener.dart';

class LogTab extends StatefulWidget {
  const LogTab({super.key});

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  String _logContent = '';
  bool _loading = true;
  Timer? _refreshTimer;
  final _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _loadLog();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) => _loadLog());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  static const _maxReadBytes = 200 * 1024; // 200 KB tail
  static const _maxLines = 500;

  Future<void> _loadLog() async {
    final path = AppLogger.logFilePath;
    if (path == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final file = File(path);
      if (!await file.exists()) {
        if (mounted) setState(() { _logContent = ''; _loading = false; });
        return;
      }

      final bytes = await file.readAsBytes();

      // Take last 200 KB to skip null-byte corruption at the beginning
      var startOffset = 0;
      if (bytes.length > _maxReadBytes) {
        startOffset = bytes.length - _maxReadBytes;
        // Align to next newline for a clean line boundary
        while (startOffset < bytes.length && bytes[startOffset] != 10) {
          startOffset++;
        }
        if (startOffset < bytes.length) startOffset++;
      }

      // Filter out null bytes and decode
      final filtered = bytes.sublist(startOffset).where((b) => b != 0).toList();
      var content = utf8.decode(filtered, allowMalformed: true);

      // Limit to last N lines
      final lines = content.split('\n');
      if (lines.length > _maxLines) {
        content = lines.sublist(lines.length - _maxLines).join('\n');
      }

      if (!mounted) return;
      final changed = content != _logContent;
      setState(() {
        _logContent = content;
        _loading = false;
      });
      if (changed && _autoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e, s) {
      AppLogger.error('Failed to read log file', error: e, stackTrace: s);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _clearLog() async {
    final path = AppLogger.logFilePath;
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.writeAsString('');
      if (mounted) setState(() => _logContent = '');
    } catch (e) {
      AppLogger.warn('Failed to clear log file', error: e);
    }
  }

  Future<void> _exportLogs() async {
    final logPath = AppLogger.logFilePath;
    if (logPath == null) return;
    final file = File(logPath);
    if (!await file.exists()) return;
    await FileOpener.share(logPath);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(l.cloudDiagnostics, style: theme.textTheme.titleMedium),
              ),
              IconButton(
                icon: Icon(
                  _autoScroll ? Icons.vertical_align_bottom : Icons.vertical_align_bottom_outlined,
                  color: _autoScroll ? theme.colorScheme.primary : null,
                ),
                tooltip: 'Auto-scroll',
                onPressed: () => setState(() => _autoScroll = !_autoScroll),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy',
                onPressed: _logContent.isEmpty
                    ? null
                    : () => Clipboard.setData(ClipboardData(text: _logContent)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear',
                onPressed: _logContent.isEmpty ? null : _clearLog,
              ),
              const SizedBox(width: 4),
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share, size: 18),
                  label: Text(l.cloudExportLogs),
                  onPressed: _exportLogs,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _logContent.isEmpty
                  ? Center(
                      child: Text(
                        'No log data',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(
                          _logContent,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

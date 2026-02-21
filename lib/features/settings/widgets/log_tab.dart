import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

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
      final content = await file.readAsString();
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
    } catch (_) {
      if (mounted) setState(() => _loading = false);
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

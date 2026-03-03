import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';

class AiInputBar extends StatefulWidget {
  const AiInputBar({
    super.key,
    required this.onSend,
    required this.isEnabled,
    required this.onTranscribe,
  });

  final ValueChanged<String> onSend;
  final bool isEnabled;
  final Future<String> Function(List<int> audioBytes, String mimeType) onTranscribe;

  @override
  State<AiInputBar> createState() => _AiInputBarState();
}

class _AiInputBarState extends State<AiInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;
  bool _isRecording = false;
  bool _isTranscribing = false;
  AudioRecorder? _recorder;
  Timer? _autoStopTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    _recorder?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.isEnabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopAndTranscribe();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording || _isTranscribing) return;
    try {
      _recorder ??= AudioRecorder();

      final hasPermission = await _recorder!.hasPermission();
      if (!hasPermission) {
        AppLogger.warn('Microphone permission denied', tag: 'AI');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/ai_voice_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder!.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );

      setState(() => _isRecording = true);

      // Auto-stop after 60s safety limit
      _autoStopTimer = Timer(const Duration(seconds: 60), () {
        if (_isRecording) {
          _stopAndTranscribe();
        }
      });
    } catch (e, s) {
      AppLogger.error('Failed to start recording', tag: 'AI', error: e, stackTrace: s);
      setState(() => _isRecording = false);
    }
  }

  Future<void> _stopAndTranscribe() async {
    if (!_isRecording) return;
    _autoStopTimer?.cancel();

    File? file;
    try {
      final path = await _recorder!.stop();
      setState(() {
        _isRecording = false;
        _isTranscribing = true;
      });

      if (path == null) {
        return;
      }

      file = File(path);
      final bytes = await file.readAsBytes();

      final text = await widget.onTranscribe(bytes, 'audio/wav');

      if (text.trim().isNotEmpty) {
        _controller.text = _controller.text.isEmpty
            ? text.trim()
            : '${_controller.text} ${text.trim()}';
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
      }
    } catch (e, s) {
      AppLogger.error('Failed to transcribe audio', tag: 'AI', error: e, stackTrace: s);
    } finally {
      try { await file?.delete(); } catch (_) {}
      if (mounted) {
        setState(() => _isTranscribing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.isEnabled && !_isRecording && !_isTranscribing,
                maxLines: 4,
                minLines: 1,
                maxLength: 4000,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: _isRecording
                      ? l.aiVoiceStop
                      : l.aiTypeMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_isTranscribing)
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_isRecording)
              IconButton(
                onPressed: _toggleRecording,
                icon: const Icon(Icons.stop),
                tooltip: l.aiVoiceStop,
                color: colorScheme.error,
              )
            else if (_hasText)
              IconButton(
                onPressed: widget.isEnabled ? _submit : null,
                icon: const Icon(Icons.send),
              )
            else
              IconButton(
                onPressed: widget.isEnabled ? _toggleRecording : null,
                icon: const Icon(Icons.mic),
                tooltip: l.aiVoiceRecord,
              ),
          ],
        ),
      ),
    );
  }
}

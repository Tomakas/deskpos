import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/display_device_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/sync/broadcast_channel.dart';
import '../../../core/widgets/pos_numpad.dart';

class ScreenDisplayCode extends ConsumerStatefulWidget {
  const ScreenDisplayCode({super.key, required this.type});
  final String type;

  @override
  ConsumerState<ScreenDisplayCode> createState() => _ScreenDisplayCodeState();
}

class _ScreenDisplayCodeState extends ConsumerState<ScreenDisplayCode> {
  String _code = '';
  bool _isLooking = false;
  bool _isWaiting = false;
  String? _error;

  BroadcastChannel? _pairingChannel;
  StreamSubscription<Map<String, dynamic>>? _pairingSub;
  Timer? _timeoutTimer;
  Timer? _retryTimer;
  String? _requestId;

  bool get _isBusy => _isLooking || _isWaiting;

  @override
  void dispose() {
    _cleanupPairing();
    super.dispose();
  }

  void _cleanupPairing() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _pairingSub?.cancel();
    _pairingSub = null;
    _pairingChannel?.leave();
    _pairingChannel = null;
    _requestId = null;
  }

  void _onDigit(String digit) {
    if (_code.length >= 6 || _isBusy) return;
    setState(() {
      _code += digit;
      _error = null;
    });
    if (_code.length == 6) _lookup();
  }

  void _onBackspace() {
    if (_code.isEmpty || _isBusy) return;
    setState(() {
      _code = _code.substring(0, _code.length - 1);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.displayCodeTitle,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l.displayCodeSubtitle,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Code dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 6; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _CodeDot(
                      filled: i < _code.length,
                      digit: i < _code.length ? _code[i] : null,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Status area
              SizedBox(
                height: _isWaiting ? 80 : 24,
                child: _isWaiting
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.displayCodeWaitingForConfirmation,
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _cancelWaiting,
                            child: Text(
                              l.actionCancel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )
                    : _isLooking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : _error != null
                            ? Text(
                                _error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: 13,
                                ),
                              )
                            : null,
              ),
              const SizedBox(height: 16),
              PosNumpad(
                width: 280,
                enabled: !_isBusy,
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                bottomLeftChild: const Icon(Icons.arrow_back),
                onBottomLeft: _isBusy ? null : () => context.go('/onboarding'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _lookup() async {
    if (_code.length != 6) return;

    setState(() {
      _isLooking = true;
      _error = null;
    });

    try {
      final repo = ref.read(displayDeviceRepositoryProvider);
      final device = await repo.lookupByCode(_code);

      if (!mounted) return;

      if (device == null) {
        setState(() {
          _isLooking = false;
          _error = context.l10n.displayCodeNotFound;
          _code = '';
        });
        return;
      }

      // Device found — request pairing confirmation from main POS
      setState(() {
        _isLooking = false;
        _isWaiting = true;
      });

      await _requestPairing(device);
    } catch (e, s) {
      AppLogger.error('Display code lookup failed', error: e, stackTrace: s);
      if (mounted) {
        setState(() {
          _isLooking = false;
          _error = context.l10n.displayCodeError;
          _code = '';
        });
      }
    }
  }

  Future<void> _requestPairing(DisplayDeviceModel device) async {
    try {
      _requestId = const Uuid().v4();
      _pairingChannel = ref.read(pairingChannelProvider);

      // Register listener BEFORE join to avoid missing messages
      _pairingSub = _pairingChannel!.stream.listen((payload) {
        final action = payload['action'] as String?;
        final code = payload['code'] as String?;
        final requestId = payload['request_id'] as String?;
        if (code != _code) return; // not for us
        if (requestId != null && requestId != _requestId) return; // not our request

        if (action == 'pairing_confirmed') {
          _onConfirmed(device);
        } else if (action == 'pairing_rejected') {
          _onRejected();
        }
      });

      await _pairingChannel!.join('pairing:${device.companyId}');

      if (!mounted) {
        _cleanupPairing();
        return;
      }

      // Send pairing request immediately, then retry every 5s
      final payload = {
        'action': 'pairing_request',
        'code': _code,
        'device_name': device.name,
        'device_type': device.type.name,
        'request_id': _requestId,
      };
      await _pairingChannel!.send(payload);
      _retryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _pairingChannel?.send(payload);
      });

      // Timeout after 60s
      _timeoutTimer = Timer(const Duration(seconds: 60), _onTimeout);
    } catch (e, s) {
      AppLogger.error('Pairing request failed', error: e, stackTrace: s);
      _cleanupPairing();
      if (mounted) {
        setState(() {
          _isWaiting = false;
          _error = context.l10n.displayCodeError;
          _code = '';
        });
      }
    }
  }

  Future<void> _onConfirmed(DisplayDeviceModel device) async {
    if (!mounted) return;
    _cleanupPairing();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('display_code', _code);
      await prefs.setString('display_type', widget.type);
      await prefs.setString('display_company_id', device.companyId);
      await prefs.setString('display_welcome_text', device.welcomeText);

      if (!mounted) return;

      AppLogger.info(
        'Display device paired: code=$_code type=${widget.type}',
        tag: 'DISPLAY',
      );

      ref.invalidate(appInitProvider);
      await ref.read(appInitProvider.future);

      if (!mounted) return;

      context.go('/customer-display');
    } catch (e, s) {
      AppLogger.error('Pairing finalization failed', error: e, stackTrace: s);
      if (mounted) {
        setState(() {
          _isWaiting = false;
          _error = context.l10n.displayCodeError;
          _code = '';
        });
      }
    }
  }

  void _onRejected() {
    if (!mounted) return;
    _cleanupPairing();
    setState(() {
      _isWaiting = false;
      _error = context.l10n.displayCodeRejected;
      _code = '';
    });
  }

  void _onTimeout() {
    if (!mounted) return;
    _cleanupPairing();
    setState(() {
      _isWaiting = false;
      _error = context.l10n.displayCodeTimeout;
      _code = '';
    });
  }

  void _cancelWaiting() {
    _cleanupPairing();
    setState(() {
      _isWaiting = false;
      _code = '';
    });
  }
}

// ---------------------------------------------------------------------------
// Single code digit dot
// ---------------------------------------------------------------------------

class _CodeDot extends StatelessWidget {
  const _CodeDot({required this.filled, this.digit});
  final bool filled;
  final String? digit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 44,
      height: 52,
      decoration: BoxDecoration(
        color: filled
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: filled
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: filled ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        digit ?? '',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
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
  String? _error;

  void _onDigit(String digit) {
    if (_code.length >= 6 || _isLooking) return;
    setState(() {
      _code += digit;
      _error = null;
    });
    if (_code.length == 6) _lookup();
  }

  void _onBackspace() {
    if (_code.isEmpty || _isLooking) return;
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
              // Error / loading
              SizedBox(
                height: 24,
                child: _isLooking
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
                enabled: !_isLooking,
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                bottomLeftChild: const Icon(Icons.arrow_back),
                onBottomLeft: () => context.go('/onboarding'),
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('display_code', _code);
      await prefs.setString('display_type', widget.type);
      await prefs.setString('display_company_id', device.companyId);

      AppLogger.info(
        'Display device paired: code=$_code type=${widget.type}',
        tag: 'DISPLAY',
      );

      ref.invalidate(appInitProvider);
      await ref.read(appInitProvider.future);

      if (!mounted) return;

      if (widget.type == 'customer_display') {
        context.go('/customer-display');
      } else {
        context.go('/connect-company');
      }
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/models/customer_display_content.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';

/// Customer-facing display that shows content via Supabase Broadcast.
///
/// This screen is designed for a secondary monitor or a tablet turned toward
/// the customer. It is read-only — no touch interaction. All data arrives
/// via Broadcast channel (~100-300ms latency).
class ScreenCustomerDisplay extends ConsumerStatefulWidget {
  const ScreenCustomerDisplay({super.key, this.code});
  final String? code;

  @override
  ConsumerState<ScreenCustomerDisplay> createState() => _ScreenCustomerDisplayState();
}

class _ScreenCustomerDisplayState extends ConsumerState<ScreenCustomerDisplay> {
  CustomerDisplayContent _content = const DisplayIdle();
  StreamSubscription<Map<String, dynamic>>? _sub;
  Timer? _autoClearTimer;
  String? _code;
  String _welcomeText = '';
  int _tapCount = 0;
  Timer? _tapResetTimer;

  @override
  void initState() {
    super.initState();
    _initBroadcast();
  }

  Future<void> _initBroadcast() async {
    // Resolve code: from param or SharedPreferences
    _code = widget.code;
    if (_code == null) {
      final prefs = await SharedPreferences.getInstance();
      _code = prefs.getString('display_code');
      _welcomeText = prefs.getString('display_welcome_text') ?? '';
      if (mounted) setState(() {});
    }

    if (_code == null || !mounted) {
      if (_code == null) {
        AppLogger.warn('CustomerDisplay: no code available, cannot join', tag: 'BROADCAST');
      }
      return;
    }

    final channel = ref.read(customerDisplayChannelProvider);
    await channel.join('display:$_code');
    _sub = channel.stream.listen(
      _onBroadcast,
      onError: (Object e, StackTrace s) {
        AppLogger.error('CustomerDisplay: stream error on display:$_code', tag: 'BROADCAST', error: e, stackTrace: s);
      },
      onDone: () {
        AppLogger.info('CustomerDisplay: stream closed for display:$_code', tag: 'BROADCAST');
      },
    );
    AppLogger.info('CustomerDisplay: joined display:$_code', tag: 'BROADCAST');
  }

  void _onBroadcast(Map<String, dynamic> payload) {
    _autoClearTimer?.cancel();
    final content = CustomerDisplayContent.fromJson(payload);
    AppLogger.debug('CustomerDisplay: received broadcast, type=${content.runtimeType}', tag: 'BROADCAST');
    setState(() => _content = content);

    // Auto-clear messages after timeout
    if (content is DisplayMessage && content.autoClearAfterMs != null) {
      _autoClearTimer = Timer(
        Duration(milliseconds: content.autoClearAfterMs!),
        () {
          if (mounted) setState(() => _content = const DisplayIdle());
        },
      );
    }
  }

  @override
  void dispose() {
    AppLogger.debug('CustomerDisplay: disposing', tag: 'BROADCAST');
    _autoClearTimer?.cancel();
    _tapResetTimer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.customerDisplayTitle),
        actions: [
          _ClockWidget(),
          const SizedBox(width: 16),
        ],
      ),
      body: switch (_content) {
        DisplayIdle() => _buildIdle(context),
        DisplayItems() => _buildItems(context, _content as DisplayItems),
        DisplayMessage() => _buildMessage(context, _content as DisplayMessage),
      },
    );
  }

  Widget _buildIdle(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final text = _welcomeText.isNotEmpty ? _welcomeText : l.customerDisplayWelcome;

    return Center(
      child: GestureDetector(
        onTap: _onIdleTap,
        child: Text(
          text,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildItems(BuildContext context, DisplayItems content) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
          ),
          child: Row(
            children: [
              Text(
                l.customerDisplayHeader,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        // Items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            itemCount: content.items.length,
            itemBuilder: (context, index) {
              final item = content.items[index];
              return _DisplayItemRow(item: item);
            },
          ),
        ),
        // Totals footer
        _BroadcastTotalsFooter(content: content),
      ],
    );
  }

  Widget _buildMessage(BuildContext context, DisplayMessage content) {
    final theme = Theme.of(context);
    final isSuccess = content.messageType == 'success';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.info_outline,
            size: 80,
            color: isSuccess ? context.appColors.success : theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            content.text,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onIdleTap() {
    _tapCount++;
    _tapResetTimer?.cancel();
    if (_tapCount >= 3) {
      _tapCount = 0;
      _disconnect();
      return;
    }
    _tapResetTimer = Timer(const Duration(milliseconds: 500), () {
      _tapCount = 0;
    });
  }

  Future<void> _disconnect() async {
    AppLogger.info('CustomerDisplay: disconnecting from display:$_code', tag: 'BROADCAST');
    final channel = ref.read(customerDisplayChannelProvider);
    channel.leave();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('display_code');
    await prefs.remove('display_type');
    await prefs.remove('display_company_id');
    await prefs.remove('display_welcome_text');

    if (!mounted) return;
    ref.invalidate(appInitProvider);

    if (mounted) context.go('/onboarding');
  }
}

// ---------------------------------------------------------------------------
// Display item row
// ---------------------------------------------------------------------------
class _DisplayItemRow extends ConsumerWidget {
  const _DisplayItemRow({required this.item});
  final DisplayItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '${ref.fmtQty(item.quantity, maxDecimals: 1)} ${item.unitLabel}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.titleMedium),
                for (final mod in item.modifiers)
                  Text(
                    '+ ${mod.name}${mod.unitPrice > 0 ? '  ${ref.money(mod.unitPrice)}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Text(
                    item.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            ref.money(item.totalPrice),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Totals footer for broadcast content
// ---------------------------------------------------------------------------
class _BroadcastTotalsFooter extends ConsumerWidget {
  const _BroadcastTotalsFooter({required this.content});
  final DisplayItems content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    final hasDiscount = content.discountAmount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _TotalRow(
            label: l.customerDisplaySubtotal,
            amount: content.subtotal,
            style: theme.textTheme.titleMedium,
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 4),
            _TotalRow(
              label: l.customerDisplayDiscount,
              amount: -content.discountAmount,
              style: theme.textTheme.titleMedium?.copyWith(
                color: context.appColors.positive,
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _TotalRow(
            label: l.customerDisplayTotal,
            amount: content.total,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends ConsumerWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    this.style,
  });
  final String label;
  final int amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(ref.money(amount), style: style),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Live clock
// ---------------------------------------------------------------------------
class _ClockWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends ConsumerState<_ClockWidget> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${ref.fmtDate(_now)}  ${ref.fmtTimeSeconds(_now)}',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/shift_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

class DialogShiftEdit extends ConsumerStatefulWidget {
  const DialogShiftEdit({
    super.key,
    required this.shift,
    required this.userName,
    this.editedByName,
  });

  final ShiftModel shift;
  final String userName;
  final String? editedByName;

  @override
  ConsumerState<DialogShiftEdit> createState() => _DialogShiftEditState();
}

class _DialogShiftEditState extends ConsumerState<DialogShiftEdit> {
  late DateTime _loginAt;
  DateTime? _logoutAt;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loginAt = widget.shift.loginAt;
    _logoutAt = widget.shift.logoutAt;
  }

  bool get _isValid {
    final now = DateTime.now();
    if (_loginAt.isAfter(now)) return false;
    final logout = _logoutAt;
    if (logout != null) {
      if (logout.isAfter(now)) return false;
      if (!logout.isAfter(_loginAt)) return false;
    }
    return true;
  }

  Future<void> _pickDate({required bool isLogin}) async {
    final current = isLogin ? _loginAt : (_logoutAt ?? DateTime.now());
    final result = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (result == null || !mounted) return;
    final time = TimeOfDay.fromDateTime(current);
    final combined = DateTime(result.year, result.month, result.day, time.hour, time.minute);
    setState(() {
      if (isLogin) {
        _loginAt = combined;
      } else {
        _logoutAt = combined;
      }
    });
  }

  Future<void> _pickTime({required bool isLogin}) async {
    final current = isLogin ? _loginAt : (_logoutAt ?? DateTime.now());
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (result == null || !mounted) return;
    final combined = DateTime(current.year, current.month, current.day, result.hour, result.minute);
    setState(() {
      if (isLogin) {
        _loginAt = combined;
      } else {
        _logoutAt = combined;
      }
    });
  }

  Future<void> _save() async {
    if (_isProcessing || !_isValid) return;
    setState(() => _isProcessing = true);
    try {
      final user = ref.read(activeUserProvider);
      if (user == null) return;

      final repo = ref.read(shiftRepositoryProvider);
      await repo.updateShift(
        id: widget.shift.id,
        loginAt: _loginAt,
        logoutAt: _logoutAt,
        editedByUserId: user.id,
      );
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _delete() async {
    if (_isProcessing) return;
    final l = context.l10n;
    final confirmed = await confirmDelete(context, l);
    if (!confirmed || !mounted) return;
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(shiftRepositoryProvider);
      await repo.softDelete(widget.shift.id);
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final canManage = ref.watch(hasPermissionProvider('shifts.manage'));
    final shift = widget.shift;

    return PosDialogShell(
      title: l.shiftDetailTitle,
      titleStyle: theme.textTheme.headlineSmall,
      maxWidth: 420,
      scrollable: true,
      bottomActions: PosDialogActions(
        leading: canManage
            ? OutlinedButton(
                onPressed: !_isProcessing ? _delete : null,
                style: PosButtonStyles.destructiveOutlined(context),
                child: Text(l.shiftEditDelete),
              )
            : null,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
          if (canManage)
            FilledButton(
              onPressed: !_isProcessing && _isValid ? _save : null,
              child: Text(l.actionSave),
            ),
        ],
      ),
      children: [
        // User name
        Text(l.shiftsColumnUser, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(widget.userName, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 12),

        // Login time
        Text(l.shiftEditLoginAt, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        if (canManage)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isLogin: true),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(ref.fmtDate(_loginAt)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickTime(isLogin: true),
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(ref.fmtTime(_loginAt)),
                ),
              ),
            ],
          )
        else
          Text(ref.fmtDateTime(shift.loginAt), style: theme.textTheme.bodyLarge),
        const SizedBox(height: 12),

        // Original login (if edited)
        if (shift.originalLoginAt != null) ...[
          Text(
            l.shiftEditOriginal(ref.fmtDateTime(shift.originalLoginAt!)),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 12),
        ],

        // Logout time
        Text(l.shiftEditLogoutAt, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        if (canManage)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isLogin: false),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _logoutAt != null ? ref.fmtDate(_logoutAt!) : l.shiftEditOngoing,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickTime(isLogin: false),
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(
                    _logoutAt != null ? ref.fmtTime(_logoutAt!) : '--:--',
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            shift.logoutAt != null ? ref.fmtDateTime(shift.logoutAt!) : l.shiftEditOngoing,
            style: theme.textTheme.bodyLarge,
          ),
        const SizedBox(height: 12),

        // Original logout (if edited)
        if (shift.originalLogoutAt != null) ...[
          Text(
            l.shiftEditOriginal(ref.fmtDateTime(shift.originalLogoutAt!)),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 12),
        ],

        // Edited by info
        if (shift.editedBy != null && widget.editedByName != null) ...[
          const Divider(),
          const SizedBox(height: 4),
          Text(
            l.shiftEditEditedBy(widget.editedByName!),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          if (shift.editedAt != null)
            Text(
              ref.fmtDateTime(shift.editedAt!),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          const SizedBox(height: 4),
        ],

        // Validation hint
        if (canManage && !_isValid) ...[
          const SizedBox(height: 8),
          Text(
            l.shiftEditValidation,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }
}

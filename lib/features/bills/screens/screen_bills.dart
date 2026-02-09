import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/data/models/section_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class ScreenBills extends ConsumerWidget {
  const ScreenBills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final activeUser = ref.watch(activeUserProvider);
    final loggedIn = ref.watch(loggedInUsersProvider);
    final canManageSettings = ref.watch(hasPermissionProvider('settings.manage'));

    return Scaffold(
      body: Row(
        children: [
          // Left panel (80%)
          Expanded(
            flex: 4,
            child: Column(
              children: [
                // Section tabs
                _SectionTabBar(l: l),
                // Bills table
                Expanded(child: _BillsTable(l: l)),
                // Status filter bar
                _StatusFilterBar(l: l),
              ],
            ),
          ),
          // Right panel (20%)
          SizedBox(
            width: 240,
            child: _RightPanel(
              l: l,
              activeUser: activeUser,
              loggedInUsers: loggedIn,
              canManageSettings: canManageSettings,
              onLogout: () => _logout(context, ref),
              onSwitchUser: () => _showSwitchUserDialog(context, ref),
              onSettings: canManageSettings ? () => context.push('/settings') : null,
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    final session = ref.read(sessionManagerProvider);
    session.logoutActive();
    ref.read(activeUserProvider.notifier).state = session.activeUser;
    ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
    if (!session.isAuthenticated) {
      context.go('/login');
    }
  }

  void _showSwitchUserDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _SwitchUserDialog(ref: ref),
    );
  }
}

class _SectionTabBar extends ConsumerStatefulWidget {
  const _SectionTabBar({required this.l});
  final dynamic l;

  @override
  ConsumerState<_SectionTabBar> createState() => _SectionTabBarState();
}

class _SectionTabBarState extends ConsumerState<_SectionTabBar> {
  String? _selectedSectionId;

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<SectionModel>>(
      stream: ref.watch(sectionRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final sections = snap.data ?? [];

        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text(widget.l.billsSectionAll),
                  selected: _selectedSectionId == null,
                  onSelected: (_) => setState(() => _selectedSectionId = null),
                ),
                for (final section in sections) ...[
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(section.name),
                    selected: _selectedSectionId == section.id,
                    onSelected: (_) => setState(() => _selectedSectionId = section.id),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BillsTable extends StatelessWidget {
  const _BillsTable({required this.l});
  final dynamic l;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              _HeaderCell(l.columnTable, flex: 2),
              _HeaderCell(l.columnGuest, flex: 2),
              _HeaderCell(l.columnGuests, flex: 1),
              _HeaderCell(l.columnTotal, flex: 2),
              _HeaderCell(l.columnLastOrder, flex: 2),
              _HeaderCell(l.columnStaff, flex: 2),
            ],
          ),
        ),
        // Empty state
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, {required this.flex});
  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusFilterBar extends StatefulWidget {
  const _StatusFilterBar({required this.l});
  final dynamic l;

  @override
  State<_StatusFilterBar> createState() => _StatusFilterBarState();
}

class _StatusFilterBarState extends State<_StatusFilterBar> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final labels = [l.billsFilterOpened, l.billsFilterPaid, l.billsFilterCancelled];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            FilterChip(
              label: Text(labels[i]),
              selected: _selected == i,
              onSelected: (_) => setState(() => _selected = i),
            ),
          ],
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({
    required this.l,
    required this.activeUser,
    required this.loggedInUsers,
    required this.canManageSettings,
    required this.onLogout,
    required this.onSwitchUser,
    required this.onSettings,
  });

  final dynamic l;
  final dynamic activeUser;
  final List loggedInUsers;
  final bool canManageSettings;
  final VoidCallback onLogout;
  final VoidCallback onSwitchUser;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.dividerColor)),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 44,
                  child: FilledButton.tonal(
                    onPressed: null,
                    child: Text(l.billsQuickBill),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: null,
                    child: Text(l.billsNewBill),
                  ),
                ),
                if (onSettings != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onSettings,
                      child: Text(l.settingsTitle),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          // Info panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(l.infoPanelStatus, l.infoPanelStatusOffline),
                const SizedBox(height: 4),
                _InfoRow(
                  l.infoPanelActiveUser,
                  activeUser?.fullName ?? '-',
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  l.infoPanelLoggedIn,
                  loggedInUsers.map((u) => u.fullName).join(', '),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onSwitchUser,
                    child: Text(l.actionSwitchUser),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                    onPressed: onLogout,
                    child: Text(l.actionLogout),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _SwitchUserDialog extends StatefulWidget {
  const _SwitchUserDialog({required this.ref});
  final WidgetRef ref;

  @override
  State<_SwitchUserDialog> createState() => _SwitchUserDialogState();
}

class _SwitchUserDialogState extends State<_SwitchUserDialog> {
  String? _selectedUserId;
  final _pinCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final session = widget.ref.read(sessionManagerProvider);
    final activeUser = session.activeUser;
    final loggedIn = session.loggedInUsers;

    // If a user is selected, show PIN entry
    if (_selectedUserId != null) {
      final selectedUser = loggedIn.firstWhere((u) => u.id == _selectedUserId);
      return AlertDialog(
        title: Text(l.switchUserEnterPin(selectedUser.fullName)),
        content: TextField(
          controller: _pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.loginPinLabel,
            errorText: _error,
          ),
          onSubmitted: (_) => _verifyAndSwitch(),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _selectedUserId = null;
              _pinCtrl.clear();
              _error = null;
            }),
            child: Text(l.wizardBack),
          ),
          FilledButton(
            onPressed: _verifyAndSwitch,
            child: Text(l.loginButton),
          ),
        ],
      );
    }

    // Show user list
    return AlertDialog(
      title: Text(l.switchUserTitle),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.switchUserSelectUser),
            const SizedBox(height: 16),
            ...loggedIn.where((u) => u.id != activeUser?.id).map(
                  (user) => ListTile(
                    title: Text(user.fullName),
                    subtitle: Text(user.username),
                    onTap: () {
                      setState(() => _selectedUserId = user.id);
                    },
                  ),
                ),
            // New user login
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l.loginTitle),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionClose),
        ),
      ],
    );
  }

  void _verifyAndSwitch() {
    final session = widget.ref.read(sessionManagerProvider);
    final authService = widget.ref.read(authServiceProvider);
    final user = session.loggedInUsers.firstWhere((u) => u.id == _selectedUserId);

    final result = authService.authenticate(_pinCtrl.text, user.pinHash);
    switch (result) {
      case AuthSuccess():
        session.switchTo(user.id);
        widget.ref.read(activeUserProvider.notifier).state = session.activeUser;
        widget.ref.read(loggedInUsersProvider.notifier).state = session.loggedInUsers;
        if (mounted) Navigator.of(context).pop();
      case AuthFailure(message: final msg):
        setState(() {
          _error = msg;
          _pinCtrl.clear();
        });
      case AuthLocked(remainingSeconds: final secs):
        setState(() {
          _error = context.l10n.loginLockedOut(secs);
          _pinCtrl.clear();
        });
    }
  }
}

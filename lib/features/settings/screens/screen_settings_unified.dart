import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/permission_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/cloud_tab.dart';
import '../widgets/company_info_tab.dart';
import '../widgets/floor_map_editor_tab.dart';
import '../widgets/log_tab.dart';
import '../widgets/mode_tab.dart';
import '../widgets/payment_methods_tab.dart';
import '../widgets/register_tab.dart';
import '../widgets/registers_tab.dart';
import '../widgets/sections_tab.dart';
import '../widgets/security_tab.dart';
import '../widgets/tables_tab.dart';
import '../widgets/tax_rates_tab.dart';
import '../widgets/users_tab.dart';

class ScreenSettingsUnified extends ConsumerStatefulWidget {
  const ScreenSettingsUnified({super.key});

  @override
  ConsumerState<ScreenSettingsUnified> createState() => _ScreenSettingsUnifiedState();
}

class _ScreenSettingsUnifiedState extends ConsumerState<ScreenSettingsUnified>
    with TickerProviderStateMixin {
  TabController? _topController;
  final Map<int, TabController> _innerControllers = {};
  List<_TopTab> _visibleTabs = [];

  @override
  void initState() {
    super.initState();
    // Listen for permission changes and rebuild tabs safely (outside build).
    ref.listenManual(hasAnyPermissionInGroupProvider('settings_company'), (_, __) => _schedulRebuild());
    ref.listenManual(hasAnyPermissionInGroupProvider('settings_venue'), (_, __) => _schedulRebuild());
    ref.listenManual(hasAnyPermissionInGroupProvider('settings_register'), (_, __) => _schedulRebuild());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildTabs();
  }

  void _schedulRebuild() {
    if (!mounted) return;
    // Defer so we never dispose controllers inside build().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _rebuildTabs());
    });
  }

  void _rebuildTabs() {
    final canCompany = ref.read(hasAnyPermissionInGroupProvider('settings_company'));
    final canVenue = ref.read(hasAnyPermissionInGroupProvider('settings_venue'));
    final canRegister = ref.read(hasAnyPermissionInGroupProvider('settings_register'));

    final tabs = <_TopTab>[
      if (canCompany) _TopTab.company,
      if (canVenue) _TopTab.venue,
      if (canRegister) _TopTab.register,
    ];

    if (_listEquals(tabs, _visibleTabs)) return;

    final oldTab = _visibleTabs.isNotEmpty && _topController != null
        ? _visibleTabs[_topController!.index]
        : null;

    _visibleTabs = tabs;

    _topController?.removeListener(_onTopTabChanged);
    _topController?.dispose();
    _topController = tabs.isNotEmpty
        ? TabController(
            length: tabs.length,
            vsync: this,
            initialIndex: oldTab != null
                ? tabs.indexOf(oldTab).clamp(0, tabs.length - 1)
                : 0,
          )
        : null;
    _topController?.addListener(_onTopTabChanged);

    for (final c in _innerControllers.values) {
      c.dispose();
    }
    _innerControllers.clear();
    for (var i = 0; i < tabs.length; i++) {
      _innerControllers[i] = TabController(
        length: _innerTabCount(tabs[i]),
        vsync: this,
      );
    }
  }

  static bool _listEquals(List<_TopTab> a, List<_TopTab> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _topController?.removeListener(_onTopTabChanged);
    _topController?.dispose();
    for (final c in _innerControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTopTabChanged() {
    if (_topController != null && !_topController!.indexIsChanging) {
      setState(() {});
    }
  }

  int _innerTabCount(_TopTab tab) {
    switch (tab) {
      case _TopTab.company:
        return 7;
      case _TopTab.venue:
        return 4;
      case _TopTab.register:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (_visibleTabs.isEmpty || _topController == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.settingsTitle)),
        body: const SizedBox.shrink(),
      );
    }

    final topIndex = _topController!.index.clamp(0, _visibleTabs.length - 1);
    final currentTop = _visibleTabs[topIndex];
    final innerController = _innerControllers[topIndex]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsTitle),
        bottom: TabBar(
          controller: _topController,
          tabs: [
            for (final tab in _visibleTabs) Tab(text: _topTabLabel(l, tab)),
          ],
        ),
      ),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: TabBar(
              controller: innerController,
              tabs: _innerTabs(l, currentTop),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: innerController,
              children: _innerViews(currentTop),
            ),
          ),
        ],
      ),
    );
  }

  String _topTabLabel(AppLocalizations l, _TopTab tab) {
    switch (tab) {
      case _TopTab.company:
        return l.settingsTabCompany;
      case _TopTab.venue:
        return l.settingsTabVenue;
      case _TopTab.register:
        return l.settingsTabRegister;
    }
  }

  List<Tab> _innerTabs(AppLocalizations l, _TopTab tab) {
    switch (tab) {
      case _TopTab.company:
        return [
          Tab(text: l.settingsTabInfo),
          Tab(text: l.settingsTabUsers),
          Tab(text: l.settingsSectionSecurity),
          Tab(text: l.settingsSectionCloud),
          Tab(text: l.settingsTaxRates),
          Tab(text: l.settingsPaymentMethods),
          Tab(text: l.settingsTabLog),
        ];
      case _TopTab.venue:
        return [
          Tab(text: l.settingsSections),
          Tab(text: l.settingsTables),
          Tab(text: l.settingsFloorMap),
          Tab(text: l.settingsRegisters),
        ];
      case _TopTab.register:
        return [
          Tab(text: l.modeTitle),
          Tab(text: l.sellTitle),
        ];
    }
  }

  List<Widget> _innerViews(_TopTab tab) {
    switch (tab) {
      case _TopTab.company:
        return const [
          CompanyInfoTab(),
          UsersTab(),
          SecurityTab(),
          CloudTab(),
          TaxRatesTab(),
          PaymentMethodsTab(),
          LogTab(),
        ];
      case _TopTab.venue:
        return const [
          SectionsTab(),
          TablesTab(),
          FloorMapEditorTab(),
          RegistersTab(),
        ];
      case _TopTab.register:
        return const [
          ModeTab(),
          RegisterTab(),
        ];
    }
  }
}

enum _TopTab { company, venue, register }

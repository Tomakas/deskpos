import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/permission_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/cloud_tab.dart';
import '../widgets/company_info_tab.dart';
import '../widgets/fiscal_tab.dart';
import '../widgets/floor_map_editor_tab.dart';
import '../widgets/log_tab.dart';
import '../widgets/mode_tab.dart';
import '../widgets/payment_methods_tab.dart';
import '../widgets/register_tab.dart';
import '../widgets/peripherals_tab.dart';
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
  // Cached inner tab definitions per top-level tab index.
  final Map<int, List<_InnerTabDef>> _innerTabDefs = {};

  @override
  void initState() {
    super.initState();
    // Listen for permission changes and rebuild tabs safely (outside build).
    ref.listenManual(hasAnyPermissionInGroupProvider('settings_company'), (_, _) => _scheduleRebuild());
    ref.listenManual(hasAnyPermissionInGroupProvider('settings_venue'), (_, _) => _scheduleRebuild());
    ref.listenManual(hasAnyPermissionInGroupProvider('settings_register'), (_, _) => _scheduleRebuild());
    // Cross-group permissions that affect settings visibility.
    ref.listenManual(hasPermissionProvider('users.view'), (_, _) => _scheduleRebuild());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildTabs();
  }

  void _scheduleRebuild() {
    if (!mounted) return;
    // Defer so we never dispose controllers inside build().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _rebuildTabs());
    });
  }

  List<_InnerTabDef> _buildInnerTabs(_TopTab tab) {
    final l = context.l10n;
    bool p(String code) => ref.read(hasPermissionProvider(code));
    switch (tab) {
      case _TopTab.company:
        return [
          if (p('settings_company.info'))
            _InnerTabDef(l.settingsTabInfo, const CompanyInfoTab()),
          if (p('users.view'))
            _InnerTabDef(l.settingsTabUsers, const UsersTab()),
          if (p('settings_company.security'))
            _InnerTabDef(l.settingsSectionSecurity, const SecurityTab()),
          if (p('settings_company.cloud'))
            _InnerTabDef(l.settingsSectionCloud, const CloudTab()),
          if (p('settings_company.fiscal'))
            _InnerTabDef(l.settingsTabFiscal, const FiscalTab()),
          if (p('settings_register.tax_rates'))
            _InnerTabDef(l.settingsTaxRates, const TaxRatesTab()),
          if (p('settings_register.payment_methods'))
            _InnerTabDef(l.settingsPaymentMethods, const PaymentMethodsTab()),
          if (p('settings_company.view_log'))
            _InnerTabDef(l.settingsTabLog, const LogTab()),
        ];
      case _TopTab.venue:
        return [
          if (p('settings_venue.sections'))
            _InnerTabDef(l.settingsSections, const SectionsTab()),
          if (p('settings_venue.tables'))
            _InnerTabDef(l.settingsTables, const TablesTab()),
          if (p('settings_venue.floor_plan'))
            _InnerTabDef(l.settingsFloorMap, const FloorMapEditorTab()),
          if (p('settings_register.manage_devices'))
            _InnerTabDef(l.settingsRegisters, const RegistersTab()),
        ];
      case _TopTab.register:
        return [
          if (p('settings_register.manage'))
            _InnerTabDef(l.modeTitle, const ModeTab()),
          if (p('settings_register.manage'))
            _InnerTabDef(l.sellTitle, const RegisterTab()),
          if (p('settings_register.hardware'))
            _InnerTabDef(l.peripheralsTitle, const PeripheralsTab()),
        ];
    }
  }

  void _rebuildTabs() {
    // Build inner tab lists first — top-level tab visible only if inner list is non-empty.
    final companyInner = _buildInnerTabs(_TopTab.company);
    final venueInner = _buildInnerTabs(_TopTab.venue);
    final registerInner = _buildInnerTabs(_TopTab.register);

    final tabs = <_TopTab>[
      if (companyInner.isNotEmpty) _TopTab.company,
      if (venueInner.isNotEmpty) _TopTab.venue,
      if (registerInner.isNotEmpty) _TopTab.register,
    ];

    // Build inner-tab map keyed by position in new tabs list.
    final newInnerDefs = <int, List<_InnerTabDef>>{};
    for (var i = 0; i < tabs.length; i++) {
      newInnerDefs[i] = switch (tabs[i]) {
        _TopTab.company => companyInner,
        _TopTab.venue => venueInner,
        _TopTab.register => registerInner,
      };
    }

    // Check if anything actually changed.
    if (_listEquals(tabs, _visibleTabs) && _innerDefsEqual(newInnerDefs)) return;

    final oldTab = _visibleTabs.isNotEmpty && _topController != null
        ? _visibleTabs[_topController!.index]
        : null;

    _visibleTabs = tabs;
    _innerTabDefs
      ..clear()
      ..addAll(newInnerDefs);

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
        length: _innerTabDefs[i]!.length,
        vsync: this,
      );
    }
  }

  bool _innerDefsEqual(Map<int, List<_InnerTabDef>> newDefs) {
    if (newDefs.length != _innerTabDefs.length) return false;
    for (final entry in newDefs.entries) {
      final old = _innerTabDefs[entry.key];
      if (old == null || old.length != entry.value.length) return false;
      for (var i = 0; i < old.length; i++) {
        if (old[i].label != entry.value[i].label) return false;
      }
    }
    return true;
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
    final innerDefs = _innerTabDefs[topIndex] ?? [];
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
              tabs: [for (final def in innerDefs) Tab(text: def.label)],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: innerController,
              children: [for (final def in innerDefs) def.view],
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
}

enum _TopTab { company, venue, register }

class _InnerTabDef {
  const _InnerTabDef(this.label, this.view);
  final String label;
  final Widget view;
}

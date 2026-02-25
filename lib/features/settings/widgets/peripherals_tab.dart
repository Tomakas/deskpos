import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations_ext.dart';

class PeripheralsTab extends StatelessWidget {
  const PeripheralsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // --- Scanner ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l.peripheralsScanner,
            style: theme.textTheme.titleMedium,
          ),
        ),
        SwitchListTile(
          title: Text(l.peripheralsScannerEnabled),
          value: false,
          onChanged: (_) {},
        ),
        ListTile(
          title: Text(l.peripheralsScannerConnection),
          trailing: SizedBox(
            width: 160,
            child: DropdownButtonFormField<String>(
              initialValue: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: Text(l.peripheralsNotConfigured),
              items: [
                DropdownMenuItem(value: 'usb', child: Text('USB')),
                DropdownMenuItem(value: 'bluetooth', child: Text('Bluetooth')),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
        const Divider(),

        // --- Cash Drawer ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l.peripheralsCashDrawer,
            style: theme.textTheme.titleMedium,
          ),
        ),
        SwitchListTile(
          title: Text(l.peripheralsCashDrawerOpenOnPayment),
          value: false,
          onChanged: (_) {},
        ),
        ListTile(
          title: Text(l.peripheralsCashDrawerConnection),
          trailing: SizedBox(
            width: 160,
            child: DropdownButtonFormField<String>(
              initialValue: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: Text(l.peripheralsNotConfigured),
              items: [
                DropdownMenuItem(value: 'usb', child: Text('USB')),
                DropdownMenuItem(value: 'network', child: Text('Network')),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
        const Divider(),

        // --- Receipt Printer ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l.peripheralsPrinter,
            style: theme.textTheme.titleMedium,
          ),
        ),
        SwitchListTile(
          title: Text(l.peripheralsPrinterAutoPrint),
          value: false,
          onChanged: (_) {},
        ),
        ListTile(
          title: Text(l.peripheralsPrinterConnection),
          trailing: SizedBox(
            width: 160,
            child: DropdownButtonFormField<String>(
              initialValue: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: Text(l.peripheralsNotConfigured),
              items: [
                DropdownMenuItem(value: 'usb', child: Text('USB')),
                DropdownMenuItem(value: 'bluetooth', child: Text('Bluetooth')),
                DropdownMenuItem(value: 'network', child: Text('Network')),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
        const Divider(),

        // --- Payment Terminal ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l.peripheralsTerminal,
            style: theme.textTheme.titleMedium,
          ),
        ),
        ListTile(
          title: Text(l.peripheralsTerminalConnection),
          trailing: SizedBox(
            width: 160,
            child: DropdownButtonFormField<String>(
              initialValue: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: Text(l.peripheralsNotConfigured),
              items: [
                DropdownMenuItem(value: 'usb', child: Text('USB')),
                DropdownMenuItem(value: 'network', child: Text('Network')),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}

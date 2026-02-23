import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'pos_dialog_actions.dart';
import 'pos_dialog_theme.dart';

class PosDialogShell extends StatelessWidget {
  const PosDialogShell({
    super.key,
    required this.title,
    this.titleWidget,
    required this.children,
    this.maxWidth = 420,
    this.maxHeight,
    this.padding = const EdgeInsets.all(PosDialogTheme.padding),
    this.titleStyle,
    this.scrollable = false,
    this.expandHeight = false,
  });

  final String title;
  final Widget? titleWidget;
  final List<Widget> children;
  final double maxWidth;
  final double? maxHeight;
  final EdgeInsets padding;
  final TextStyle? titleStyle;
  final bool scrollable;
  final bool expandHeight;

  @override
  Widget build(BuildContext context) {
    final style = titleStyle ?? Theme.of(context).textTheme.titleLarge;
    final content = <Widget>[
      titleWidget != null ? Center(child: titleWidget!) : Center(child: Text(title, style: style)),
      const SizedBox(height: PosDialogTheme.sectionSpacing),
      ...children,
    ];

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: Padding(
          padding: padding,
          child: scrollable
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: content,
                  ),
                )
              : Column(
                  mainAxisSize: expandHeight ? MainAxisSize.max : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: content,
                ),
        ),
      ),
    );
  }
}

/// Shows a simple Yes / No confirmation dialog.
/// Returns `true` when the user confirms, `false` otherwise.
Future<bool> confirmDelete(BuildContext context, AppLocalizations l) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => PosDialogShell(
      title: l.confirmDelete,
      children: [
        PosDialogActions(
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.no)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.yes)),
          ],
        ),
      ],
    ),
  );
  return confirmed == true;
}

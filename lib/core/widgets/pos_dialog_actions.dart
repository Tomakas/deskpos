import 'package:flutter/material.dart';

import 'pos_dialog_theme.dart';

class PosDialogActions extends StatelessWidget {
  const PosDialogActions({
    super.key,
    required this.actions,
    this.leading,
    this.height = PosDialogTheme.actionHeight,
    this.spacing = PosDialogTheme.actionSpacing,
    this.expanded = false,
  });

  final List<Widget> actions;
  final Widget? leading;
  final double height;
  final double spacing;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget row;

    if (leading != null) {
      row = Row(
        children: [
          SizedBox.expand(child: leading!),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0) SizedBox(width: spacing),
                  SizedBox(height: double.infinity, child: actions[i]),
                ],
              ],
            ),
          ),
        ],
      );
    } else {
      row = Row(
        mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            if (expanded)
              Expanded(child: SizedBox(height: double.infinity, child: actions[i]))
            else
              SizedBox(height: double.infinity, child: actions[i]),
          ],
        ],
      );
    }

    return SizedBox(height: height, child: row);
  }
}

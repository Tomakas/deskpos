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
    if (leading != null) {
      return Row(
        children: [
          SizedBox(height: height, child: leading!),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0) SizedBox(width: spacing),
                  SizedBox(height: height, child: actions[i]),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          if (expanded)
            Expanded(child: SizedBox(height: height, child: actions[i]))
          else
            SizedBox(height: height, child: actions[i]),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'pos_dialog_theme.dart';

class PosDialogActions extends StatelessWidget {
  const PosDialogActions({
    super.key,
    required this.actions,
    this.height = PosDialogTheme.actionHeight,
    this.spacing = PosDialogTheme.actionSpacing,
  });

  final List<Widget> actions;
  final double height;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(
            child: SizedBox(
              height: height,
              child: actions[i],
            ),
          ),
        ],
      ],
    );
  }
}

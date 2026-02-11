import 'package:flutter/material.dart';

import 'pos_dialog_theme.dart';

class PosDialogShell extends StatelessWidget {
  const PosDialogShell({
    super.key,
    required this.title,
    required this.children,
    this.maxWidth = 420,
    this.maxHeight,
    this.padding = const EdgeInsets.all(PosDialogTheme.padding),
    this.titleStyle,
    this.scrollable = false,
  });

  final String title;
  final List<Widget> children;
  final double maxWidth;
  final double? maxHeight;
  final EdgeInsets padding;
  final TextStyle? titleStyle;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final style = titleStyle ?? Theme.of(context).textTheme.titleLarge;
    final content = <Widget>[
      Center(child: Text(title, style: style)),
      const SizedBox(height: PosDialogTheme.sectionSpacing),
      ...children,
    ];

    return Dialog(
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: content,
                ),
        ),
      ),
    );
  }
}

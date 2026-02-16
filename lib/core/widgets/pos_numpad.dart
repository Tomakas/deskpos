import 'package:flutter/material.dart';

import 'pos_dialog_theme.dart';

enum PosNumpadSize { large, compact }

class PosNumpad extends StatelessWidget {
  const PosNumpad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onClear,
    this.onDot,
    this.bottomLeftChild,
    this.onBottomLeft,
    this.size = PosNumpadSize.large,
    this.enabled = true,
    this.expand = false,
    this.width,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onClear;
  final VoidCallback? onDot;

  /// Custom widget for bottom-left position (e.g. arrow_back icon).
  /// When provided with [onBottomLeft], wrapped in the standard numpad button.
  /// When provided without [onBottomLeft], placed directly as-is.
  final Widget? bottomLeftChild;

  /// Tap callback for [bottomLeftChild]. Only used when [bottomLeftChild] is set.
  final VoidCallback? onBottomLeft;

  final PosNumpadSize size;
  final bool enabled;
  final bool expand;
  final double? width;

  double get _height => switch (size) {
        PosNumpadSize.large => PosDialogTheme.numpadLargeHeight,
        PosNumpadSize.compact => PosDialogTheme.numpadCompactHeight,
      };

  double get _radius => switch (size) {
        PosNumpadSize.large => PosDialogTheme.numpadLargeRadius,
        PosNumpadSize.compact => PosDialogTheme.numpadCompactRadius,
      };

  double get _gap => switch (size) {
        PosNumpadSize.large => PosDialogTheme.numpadLargeGap,
        PosNumpadSize.compact => PosDialogTheme.numpadCompactGap,
      };

  double get _fontSize => switch (size) {
        PosNumpadSize.large => PosDialogTheme.numpadLargeFontSize,
        PosNumpadSize.compact => PosDialogTheme.numpadCompactFontSize,
      };

  @override
  Widget build(BuildContext context) {
    final rows = [
      _buildRow(['1', '2', '3']),
      _buildRow(['4', '5', '6']),
      _buildRow(['7', '8', '9']),
      _buildBottomRow(),
    ];

    Widget content = Column(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: _gap),
          if (expand) Expanded(child: rows[i]) else rows[i],
        ],
      ],
    );

    if (width != null) {
      content = SizedBox(width: width, child: content);
    }

    return content;
  }

  Widget _buildRow(List<String> digits) {
    final row = Row(
      children: [
        for (int i = 0; i < digits.length; i++) ...[
          if (i > 0) SizedBox(width: _gap),
          Expanded(
            child: _button(
              child: Text(digits[i], style: TextStyle(fontSize: _fontSize)),
              onTap: enabled ? () => onDigit(digits[i]) : null,
            ),
          ),
        ],
      ],
    );
    return expand ? row : SizedBox(height: _height, child: row);
  }

  Widget _buildBottomRow() {
    // Determine bottom-left widget — priority: bottomLeftChild > onDot > onClear > empty
    final Widget bottomLeft;
    if (bottomLeftChild != null) {
      if (onBottomLeft != null) {
        // Wrap in standard button with tap handler
        bottomLeft = _button(
          child: bottomLeftChild!,
          onTap: enabled ? onBottomLeft : null,
        );
      } else {
        // Place directly as-is (e.g. SizedBox.shrink)
        bottomLeft = bottomLeftChild!;
      }
    } else if (onDot != null) {
      bottomLeft = _button(
        child: Text('.', style: TextStyle(fontSize: _fontSize)),
        onTap: enabled ? onDot : null,
      );
    } else if (onClear != null) {
      bottomLeft = _button(
        child: Text('C',
            style: TextStyle(
                fontSize: _fontSize, fontWeight: FontWeight.bold)),
        onTap: enabled ? onClear : null,
      );
    } else {
      bottomLeft = const SizedBox.shrink();
    }

    final row = Row(
      children: [
        Expanded(child: bottomLeft),
        SizedBox(width: _gap),
        Expanded(
          child: _button(
            child: Text('0', style: TextStyle(fontSize: _fontSize)),
            onTap: enabled ? () => onDigit('0') : null,
          ),
        ),
        SizedBox(width: _gap),
        Expanded(
          child: _button(
            child: const Icon(Icons.backspace_outlined),
            onTap: enabled ? onBackspace : null,
          ),
        ),
      ],
    );
    return expand ? row : SizedBox(height: _height, child: row);
  }

  Widget _button({required Widget child, required VoidCallback? onTap}) {
    return SizedBox(
      height: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius)),
          padding: EdgeInsets.zero,
        ),
        child: child,
      ),
    );
  }
}

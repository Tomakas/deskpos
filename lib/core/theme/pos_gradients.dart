import 'package:flutter/material.dart';

abstract final class PosGradients {
  /// Horizontal gradient for sidebar panels (cart, bills right panel).
  static LinearGradient sidePanel(ColorScheme scheme) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [scheme.surfaceContainerLow, scheme.surfaceContainerHighest],
      );
}

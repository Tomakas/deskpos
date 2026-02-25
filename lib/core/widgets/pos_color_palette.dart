import 'package:flutter/material.dart';

import '../logging/app_logger.dart';

/// Shared preset colors used across color pickers in the app.
const kColorPresets = [
  '#E53935', // Red
  '#EC407A', // Pink
  '#AB47BC', // Purple
  '#5C6BC0', // Indigo
  '#1E88E5', // Blue
  '#00ACC1', // Cyan
  '#00897B', // Teal
  '#43A047', // Green
  '#7CB342', // Light Green
  '#C0CA33', // Lime
  '#FDD835', // Yellow
  '#FFB300', // Amber
  '#FB8C00', // Orange
  '#FF5722', // Deep Orange
  '#6D4C41', // Brown
  '#78909C', // Blue Grey
  '#546E7A', // Blue Grey Dark
  '#BDBDBD', // Light Grey
  '#FFFFFF', // White
  '#000000', // Black
];

/// Parses a hex color string (e.g. '#FF9800') into a [Color].
Color parseHexColor(String? hex, {Color fallback = Colors.blueGrey}) {
  if (hex == null || hex.isEmpty) return fallback;
  try {
    final colorValue = int.parse(hex.replaceFirst('#', ''), radix: 16);
    return Color(colorValue | 0xFF000000);
  } catch (e) {
    AppLogger.warn('Invalid hex color: $hex', error: e);
    return fallback;
  }
}

/// A reusable color palette widget showing preset color circles.
///
/// [selectedColor] is the currently selected hex string.
/// [onColorSelected] is called with the chosen hex string.
class PosColorPalette extends StatelessWidget {
  const PosColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final String? selectedColor;
  final ValueChanged<String?> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final hex in kColorPresets)
          GestureDetector(
            onTap: () => onColorSelected(hex),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: parseHexColor(hex),
                border: Border.all(
                  color: selectedColor == hex
                      ? theme.colorScheme.primary
                      : hex == '#FFFFFF'
                          ? theme.dividerColor
                          : Colors.transparent,
                  width: selectedColor == hex ? 2.5 : hex == '#FFFFFF' ? 1 : 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

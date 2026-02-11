import 'package:flutter/material.dart';

/// Shared preset colors used across color pickers in the app.
const kColorPresets = [
  '#F44336', // Red
  '#E91E63', // Pink
  '#FF9800', // Orange
  '#FFC107', // Amber
  '#4CAF50', // Green
  '#009688', // Teal
  '#2196F3', // Blue
  '#3F51B5', // Indigo
  '#9C27B0', // Purple
  '#795548', // Brown
  '#607D8B', // Blue Grey
  '#000000', // Black
];

/// Parses a hex color string (e.g. '#FF9800') into a [Color].
Color parseHexColor(String? hex, {Color fallback = Colors.blueGrey}) {
  if (hex == null || hex.isEmpty) return fallback;
  try {
    final colorValue = int.parse(hex.replaceFirst('#', ''), radix: 16);
    return Color(colorValue | 0xFF000000);
  } catch (_) {
    return fallback;
  }
}

/// A reusable color palette widget showing preset color circles.
///
/// Shows a "none" option (first circle) plus all [kColorPresets].
/// [selectedColor] is the currently selected hex string (null = none).
/// [onColorSelected] is called with the chosen hex string (null = none).
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
      spacing: 8,
      runSpacing: 8,
      children: [
        // "None" / default option
        GestureDetector(
          onTap: () => onColorSelected(null),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor == null
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
                width: selectedColor == null ? 3 : 1,
              ),
            ),
            child: const Center(
              child: Icon(Icons.block, size: 16),
            ),
          ),
        ),
        // Preset colors
        for (final hex in kColorPresets)
          GestureDetector(
            onTap: () => onColorSelected(hex),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: parseHexColor(hex),
                border: Border.all(
                  color: selectedColor == hex
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

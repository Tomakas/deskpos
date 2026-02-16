import 'package:flutter/material.dart';

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
      spacing: 6,
      runSpacing: 6,
      children: [
        // "None" / default option
        GestureDetector(
          onTap: () => onColorSelected(null),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor == null
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
                width: selectedColor == null ? 2.5 : 1,
              ),
            ),
            child: const Center(
              child: Icon(Icons.block, size: 14),
            ),
          ),
        ),
        // Preset colors
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

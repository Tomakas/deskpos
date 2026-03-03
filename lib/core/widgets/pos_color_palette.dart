import 'dart:math' as math;

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

/// Predefined gradient presets stored as `linear:{angle}:{color1},{color2}`.
const kGradientPresets = [
  'linear:135:#E53935,#FF5722', // Red → Deep Orange
  'linear:135:#EC407A,#AB47BC', // Pink → Purple
  'linear:135:#AB47BC,#5C6BC0', // Purple → Indigo
  'linear:135:#5C6BC0,#1E88E5', // Indigo → Blue
  'linear:135:#1E88E5,#00ACC1', // Blue → Cyan
  'linear:135:#00ACC1,#00897B', // Cyan → Teal
  'linear:135:#00897B,#43A047', // Teal → Green
  'linear:135:#43A047,#C0CA33', // Green → Lime
  'linear:135:#FDD835,#FB8C00', // Yellow → Orange
  'linear:135:#FFB300,#E53935', // Amber → Red
  'linear:135:#FF5722,#EC407A', // Deep Orange → Pink
  'linear:135:#78909C,#546E7A', // Blue Grey → Dark
  'linear:135:#7CB342,#00897B', // Light Green → Teal
  'linear:135:#C0CA33,#FDD835', // Lime → Yellow
  'linear:135:#FB8C00,#E53935', // Orange → Red
  'linear:135:#6D4C41,#FF5722', // Brown → Deep Orange
  'linear:135:#E53935,#AB47BC', // Red → Purple
  'linear:135:#1E88E5,#43A047', // Blue → Green
  'linear:135:#FFB300,#EC407A', // Amber → Pink
  'linear:135:#00ACC1,#5C6BC0', // Cyan → Indigo
];

/// Returns true if [value] represents a gradient (starts with `linear:`).
bool isGradient(String? value) => value != null && value.startsWith('linear:');

/// Parses a gradient string like `linear:135:#E53935,#FF5722` into a
/// [LinearGradient]. Returns null for non-gradient or invalid strings.
LinearGradient? parseGradient(String? value) {
  if (value == null || !value.startsWith('linear:')) return null;
  try {
    final parts = value.split(':'); // ['linear', '135', '#E53935,#FF5722']
    final angle = double.parse(parts[1]);
    final colors = parts[2].split(',').map((h) => parseHexColor(h)).toList();
    final rad = angle * (math.pi / 180);
    return LinearGradient(
      begin: Alignment(-math.cos(rad), -math.sin(rad)),
      end: Alignment(math.cos(rad), math.sin(rad)),
      colors: colors,
    );
  } catch (e) {
    AppLogger.warn('Invalid gradient: $value', error: e);
    return null;
  }
}

/// Extracts the primary (first) color from a gradient or solid hex string.
/// Useful where only a flat [Color] is needed (borders, dialogs).
Color parsePrimaryColor(String? value, {Color fallback = Colors.blueGrey}) {
  if (value == null || value.isEmpty) return fallback;
  if (value.startsWith('linear:')) {
    final colorsPart = value.split(':').last;
    final firstHex = colorsPart.split(',').first;
    return parseHexColor(firstHex, fallback: fallback);
  }
  return parseHexColor(value, fallback: fallback);
}

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

/// Number of color circles per row in the palette.
const _kPerRow = 10;

/// Gap between circles.
const _kGap = 4.0;

/// A reusable color palette widget showing preset color circles.
///
/// Uses [LayoutBuilder] to size circles so each row fills the full
/// available width. Solid presets occupy the first rows, gradient
/// presets the remaining rows.
///
/// [selectedColor] is the currently selected hex string (or gradient string).
/// [onColorSelected] is called with the chosen value.
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final circleSize =
            (constraints.maxWidth - (_kPerRow - 1) * _kGap) / _kPerRow;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < kColorPresets.length; i += _kPerRow)
              _buildRow(
                kColorPresets.sublist(
                  i,
                  math.min(i + _kPerRow, kColorPresets.length),
                ),
                circleSize,
                theme,
              ),
            for (int i = 0; i < kGradientPresets.length; i += _kPerRow)
              _buildRow(
                kGradientPresets.sublist(
                  i,
                  math.min(i + _kPerRow, kGradientPresets.length),
                ),
                circleSize,
                theme,
              ),
          ],
        );
      },
    );
  }

  Widget _buildRow(
    List<String> items,
    double circleSize,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kGap),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: _kGap),
            GestureDetector(
              onTap: () => onColorSelected(items[i]),
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isGradient(items[i]) ? null : parseHexColor(items[i]),
                  gradient: parseGradient(items[i]),
                  border: Border.all(
                    color: selectedColor == items[i]
                        ? theme.colorScheme.primary
                        : items[i] == '#FFFFFF'
                            ? theme.dividerColor
                            : Colors.transparent,
                    width: selectedColor == items[i]
                        ? 2.5
                        : items[i] == '#FFFFFF'
                            ? 1
                            : 2.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

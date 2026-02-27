import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// AppColorsExtension — single source of truth for all semantic colors
// ---------------------------------------------------------------------------

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    // Action colors
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
    // PrepStatus
    required this.statusCreated,

    required this.statusReady,
    required this.statusDelivered,
    required this.statusVoided,
    // BillStatus
    required this.billOpened,
    required this.billPaid,
    required this.billCancelled,
    required this.billRefunded,
    // Indicators
    required this.activeIndicator,
    required this.inactiveIndicator,
    // Financial
    required this.positive,
    required this.balanced,
    required this.surplus,
    // Search
    required this.searchHighlight,
  });

  // Action
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color danger;
  final Color onDanger;

  // PrepStatus
  final Color statusCreated;

  final Color statusReady;
  final Color statusDelivered;
  final Color statusVoided;

  // BillStatus
  final Color billOpened;
  final Color billPaid;
  final Color billCancelled;
  final Color billRefunded;

  // Indicators
  final Color activeIndicator;
  final Color inactiveIndicator;

  // Financial
  final Color positive;
  final Color balanced;
  final Color surplus;

  // Search
  final Color searchHighlight;

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? danger,
    Color? onDanger,
    Color? statusCreated,

    Color? statusReady,
    Color? statusDelivered,
    Color? statusVoided,
    Color? billOpened,
    Color? billPaid,
    Color? billCancelled,
    Color? billRefunded,
    Color? activeIndicator,
    Color? inactiveIndicator,
    Color? positive,
    Color? balanced,
    Color? surplus,
    Color? searchHighlight,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      statusCreated: statusCreated ?? this.statusCreated,

      statusReady: statusReady ?? this.statusReady,
      statusDelivered: statusDelivered ?? this.statusDelivered,
      statusVoided: statusVoided ?? this.statusVoided,
      billOpened: billOpened ?? this.billOpened,
      billPaid: billPaid ?? this.billPaid,
      billCancelled: billCancelled ?? this.billCancelled,
      billRefunded: billRefunded ?? this.billRefunded,
      activeIndicator: activeIndicator ?? this.activeIndicator,
      inactiveIndicator: inactiveIndicator ?? this.inactiveIndicator,
      positive: positive ?? this.positive,
      balanced: balanced ?? this.balanced,
      surplus: surplus ?? this.surplus,
      searchHighlight: searchHighlight ?? this.searchHighlight,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      statusCreated: Color.lerp(statusCreated, other.statusCreated, t)!,

      statusReady: Color.lerp(statusReady, other.statusReady, t)!,
      statusDelivered: Color.lerp(statusDelivered, other.statusDelivered, t)!,
      statusVoided: Color.lerp(statusVoided, other.statusVoided, t)!,
      billOpened: Color.lerp(billOpened, other.billOpened, t)!,
      billPaid: Color.lerp(billPaid, other.billPaid, t)!,
      billCancelled: Color.lerp(billCancelled, other.billCancelled, t)!,
      billRefunded: Color.lerp(billRefunded, other.billRefunded, t)!,
      activeIndicator: Color.lerp(activeIndicator, other.activeIndicator, t)!,
      inactiveIndicator: Color.lerp(inactiveIndicator, other.inactiveIndicator, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      balanced: Color.lerp(balanced, other.balanced, t)!,
      surplus: Color.lerp(surplus, other.surplus, t)!,
      searchHighlight: Color.lerp(searchHighlight, other.searchHighlight, t)!,
    );
  }
}

const lightAppColors = AppColorsExtension(
  // Action
  success: Colors.green,
  onSuccess: Colors.white,
  warning: Colors.orange,
  onWarning: Colors.white,
  danger: Colors.red,
  onDanger: Colors.white,
  // PrepStatus
  statusCreated: Colors.blue,

  statusReady: Colors.green,
  statusDelivered: Colors.grey,
  statusVoided: Colors.red,
  // BillStatus
  billOpened: Colors.blue,
  billPaid: Colors.green,
  billCancelled: Colors.pink,
  billRefunded: Colors.orange,
  // Indicators
  activeIndicator: Colors.green,
  inactiveIndicator: Colors.grey,
  // Financial
  positive: Colors.green,
  balanced: Colors.green,
  surplus: Colors.blue,
  // Search
  searchHighlight: Color(0x449C27B0),
);

// ---------------------------------------------------------------------------
// BuildContext convenience getter
// ---------------------------------------------------------------------------

extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}

// ---------------------------------------------------------------------------
// Shared button styles
// ---------------------------------------------------------------------------

abstract final class PosButtonStyles {
  static ButtonStyle confirm(BuildContext context) =>
      FilledButton.styleFrom(backgroundColor: context.appColors.success);

  static ButtonStyle confirmWith(BuildContext context, {EdgeInsetsGeometry? padding, OutlinedBorder? shape}) =>
      FilledButton.styleFrom(
        backgroundColor: context.appColors.success,
        padding: padding,
        shape: shape,
      );

  static ButtonStyle destructiveFilled(BuildContext context) =>
      FilledButton.styleFrom(backgroundColor: context.appColors.danger);

  static ButtonStyle destructiveFilledWith(BuildContext context, {EdgeInsetsGeometry? padding, OutlinedBorder? shape}) =>
      FilledButton.styleFrom(
        backgroundColor: context.appColors.danger,
        padding: padding,
        shape: shape,
      );

  static ButtonStyle destructiveOutlined(BuildContext context) =>
      OutlinedButton.styleFrom(
        foregroundColor: context.appColors.danger,
        side: BorderSide(color: context.appColors.danger),
      );

  static ButtonStyle warningFilled(BuildContext context) =>
      FilledButton.styleFrom(backgroundColor: context.appColors.warning);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Color cashDifferenceColor(int diff, BuildContext context) {
  final c = context.appColors;
  if (diff == 0) return c.balanced;
  if (diff > 0) return c.surplus;
  return Theme.of(context).colorScheme.error;
}

Color boolIndicatorColor(bool value, BuildContext context) {
  final c = context.appColors;
  return value ? c.activeIndicator : c.inactiveIndicator;
}

Color valueChangeColor(num value, BuildContext context) {
  if (value > 0) return context.appColors.positive;
  return Theme.of(context).colorScheme.error;
}

/// Returns a color based on how old the last order is.
///
/// - null (no order) → red
/// - ≤ [warningMin] → blue
/// - ≤ [dangerMin] → amber/yellow
/// - ≤ [criticalMin] → orange
/// - > [criticalMin] → red
Color billAgeColor(
  DateTime? lastOrderTime, {
  required int warningMin,
  required int dangerMin,
  required int criticalMin,
}) {
  if (lastOrderTime == null) return Colors.red;
  final minutes = DateTime.now().difference(lastOrderTime).inMinutes;
  if (minutes <= warningMin) return Colors.blue;
  if (minutes <= dangerMin) return Colors.amber.shade700;
  if (minutes <= criticalMin) return Colors.orange;
  return Colors.red;
}

import '../../l10n/app_localizations.dart';
import '../data/enums/unit_type.dart';

String localizedUnitType(AppLocalizations l, UnitType type) {
  return switch (type) {
    UnitType.ks => l.unitTypeKs,
    UnitType.g => l.unitTypeG,
    UnitType.kg => l.unitTypeKg,
    UnitType.ml => l.unitTypeMl,
    UnitType.cl => l.unitTypeCl,
    UnitType.l => l.unitTypeL,
    UnitType.mm => l.unitTypeMm,
    UnitType.cm => l.unitTypeCm,
    UnitType.m => l.unitTypeM,
    UnitType.min => l.unitTypeMin,
    UnitType.h => l.unitTypeH,
  };
}

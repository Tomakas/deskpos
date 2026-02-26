import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../data/enums/business_type.dart';

class BusinessTypeSelector extends StatelessWidget {
  const BusinessTypeSelector({
    super.key,
    required this.selectedCategory,
    required this.selectedType,
    required this.onCategoryChanged,
    required this.onTypeChanged,
  });

  final BusinessCategory? selectedCategory;
  final BusinessType? selectedType;
  final ValueChanged<BusinessCategory> onCategoryChanged;
  final ValueChanged<BusinessType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final categories = BusinessCategory.values;
    final subtypes = selectedCategory != null
        ? businessTypesByCategory[selectedCategory!] ?? []
        : <BusinessType>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.businessTypeLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final (i, cat) in categories.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: FilterChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text(
                        _categoryLabel(l, cat),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    selected: selectedCategory == cat,
                    onSelected: (_) => onCategoryChanged(cat),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (selectedCategory != null && subtypes.length > 1) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<BusinessType>(
            initialValue: selectedType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              for (final type in subtypes)
                DropdownMenuItem(
                  value: type,
                  child: Text(_subtypeLabel(l, type)),
                ),
            ],
            onChanged: (v) => onTypeChanged(v),
          ),
        ],
      ],
    );
  }

  static String _categoryLabel(AppLocalizations l, BusinessCategory cat) {
    return switch (cat) {
      BusinessCategory.gastro => l.businessCategoryGastro,
      BusinessCategory.retail => l.businessCategoryRetail,
      BusinessCategory.services => l.businessCategoryServices,
      BusinessCategory.other => l.businessCategoryOther,
    };
  }

  static String _subtypeLabel(AppLocalizations l, BusinessType type) {
    return switch (type) {
      BusinessType.restaurant => l.businessTypeRestaurant,
      BusinessType.bar => l.businessTypeBar,
      BusinessType.cafe => l.businessTypeCafe,
      BusinessType.canteen => l.businessTypeCanteen,
      BusinessType.bistro => l.businessTypeBistro,
      BusinessType.bakery => l.businessTypeBakery,
      BusinessType.foodTruck => l.businessTypeFoodTruck,
      BusinessType.grocery => l.businessTypeGrocery,
      BusinessType.clothing => l.businessTypeClothing,
      BusinessType.electronics => l.businessTypeElectronics,
      BusinessType.generalStore => l.businessTypeGeneralStore,
      BusinessType.florist => l.businessTypeFlorist,
      BusinessType.hairdresser => l.businessTypeHairdresser,
      BusinessType.beautySalon => l.businessTypeBeautySalon,
      BusinessType.fitness => l.businessTypeFitness,
      BusinessType.autoService => l.businessTypeAutoService,
      BusinessType.other => l.businessTypeOther,
    };
  }
}

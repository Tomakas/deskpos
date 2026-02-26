enum BusinessType {
  // Gastro
  restaurant,
  bar,
  cafe,
  canteen,
  bistro,
  bakery,
  foodTruck,

  // Retail
  grocery,
  clothing,
  electronics,
  generalStore,
  florist,

  // Services
  hairdresser,
  beautySalon,
  fitness,
  autoService,

  // Other
  other,
}

enum BusinessCategory { gastro, retail, services, other }

const businessTypesByCategory = <BusinessCategory, List<BusinessType>>{
  BusinessCategory.gastro: [
    BusinessType.restaurant,
    BusinessType.bar,
    BusinessType.cafe,
    BusinessType.canteen,
    BusinessType.bistro,
    BusinessType.bakery,
    BusinessType.foodTruck,
  ],
  BusinessCategory.retail: [
    BusinessType.grocery,
    BusinessType.clothing,
    BusinessType.electronics,
    BusinessType.generalStore,
    BusinessType.florist,
  ],
  BusinessCategory.services: [
    BusinessType.hairdresser,
    BusinessType.beautySalon,
    BusinessType.fitness,
    BusinessType.autoService,
  ],
  BusinessCategory.other: [
    BusinessType.other,
  ],
};

extension BusinessTypeX on BusinessType {
  BusinessCategory get category {
    for (final entry in businessTypesByCategory.entries) {
      if (entry.value.contains(this)) return entry.key;
    }
    return BusinessCategory.other;
  }
}

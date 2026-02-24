import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../auth/pin_helper.dart';
import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/company_status.dart';
import '../enums/hardware_type.dart';
import '../enums/item_type.dart';
import '../enums/payment_type.dart';
import '../enums/role_name.dart';
import '../enums/table_shape.dart';
import '../enums/tax_calc_type.dart';
import '../enums/unit_type.dart';
import '../mappers/entity_mappers.dart';
import '../models/category_model.dart';
import '../models/company_model.dart';
import '../models/company_settings_model.dart';
import '../models/item_model.dart';
import '../models/manufacturer_model.dart';
import '../models/payment_method_model.dart';
import '../models/register_model.dart';
import '../models/section_model.dart';
import '../models/supplier_model.dart';
import '../models/table_model.dart';
import '../models/tax_rate_model.dart';
import '../models/user_model.dart';
import '../models/user_permission_model.dart';
import '../result.dart';

class SeedService {
  SeedService(this._db);
  final AppDatabase _db;
  final _uuid = const Uuid();

  String _id() => _uuid.v7();

  /// Seeds essential data for a new non-demo company (company, settings,
  /// tax rates, payment methods, section, register, admin user, permissions).
  /// Demo companies are created server-side via the create-demo-data edge function.
  Future<Result<String>> seedOnboarding({
    required String companyName,
    String? businessId,
    String? address,
    String? email,
    String? phone,
    required String adminFullName,
    required String adminUsername,
    required String adminPin,
    String? deviceId,
    String locale = 'cs',
    String defaultCurrencyCode = 'CZK',
    required String authUserId,
  }) async {
    try {
      // Look up server-owned global data (pulled during onboarding)
      final currencyEntity = await (_db.select(_db.currencies)
            ..where((c) => c.code.equals(defaultCurrencyCode)))
          .getSingleOrNull();
      if (currencyEntity == null) {
        return Failure('Currency $defaultCurrencyCode not found. Global data not pulled.');
      }
      final currencyId = currencyEntity.id;

      final adminRoleEntity = await (_db.select(_db.roles)
            ..where((r) => r.name.equalsValue(RoleName.admin)))
          .getSingleOrNull();
      if (adminRoleEntity == null) {
        return Failure('Admin role not found. Global data not pulled.');
      }
      final adminRoleId = adminRoleEntity.id;

      final permissionEntities = await (_db.select(_db.permissions)
            ..where((p) => p.deletedAt.isNull()))
          .get();
      if (permissionEntities.isEmpty) {
        return Failure('Permissions not found. Global data not pulled.');
      }

      final companyId = _id();
      final userId = _id();
      final registerId = _id();
      final now = DateTime.now();

      await _db.transaction(() async {
        // Bilingual helper — returns Czech or English string based on locale
        String t(String cs, String en) => locale == 'en' ? en : cs;

        // 1. Company
        final company = CompanyModel(
          id: companyId,
          name: companyName,
          status: CompanyStatus.trial,
          businessId: businessId,
          address: address,
          email: email,
          phone: phone,
          defaultCurrencyId: currencyId,
          authUserId: authUserId,
          createdAt: now,
          updatedAt: now,
        );
        await _db.into(_db.companies).insert(companyToCompanion(company));

        // 1b. Company settings (defaults)
        final settings = CompanySettingsModel(
          id: _id(),
          companyId: companyId,
          locale: locale,
          createdAt: now,
          updatedAt: now,
        );
        await _db.into(_db.companySettings).insert(companySettingsToCompanion(settings));

        // 2. Tax rates
        final taxRates = [
          TaxRateModel(
            id: _id(),
            companyId: companyId,
            label: t('Základní 21%', 'Standard 21%'),
            type: TaxCalcType.regular,
            rate: 2100,
            isDefault: true,
            createdAt: now,
            updatedAt: now,
          ),
          TaxRateModel(
            id: _id(),
            companyId: companyId,
            label: t('Snížená 12%', 'Reduced 12%'),
            type: TaxCalcType.regular,
            rate: 1200,
            createdAt: now,
            updatedAt: now,
          ),
          TaxRateModel(
            id: _id(),
            companyId: companyId,
            label: t('Nulová 0%', 'Zero 0%'),
            type: TaxCalcType.noTax,
            rate: 0,
            createdAt: now,
            updatedAt: now,
          ),
        ];
        for (final tr in taxRates) {
          await _db.into(_db.taxRates).insert(taxRateToCompanion(tr));
        }

        // 3. Payment methods
        final paymentMethods = [
          PaymentMethodModel(
            id: _id(),
            companyId: companyId,
            name: t('Hotovost', 'Cash'),
            type: PaymentType.cash,
            createdAt: now,
            updatedAt: now,
          ),
          PaymentMethodModel(
            id: _id(),
            companyId: companyId,
            name: t('Karta', 'Card'),
            type: PaymentType.card,
            createdAt: now,
            updatedAt: now,
          ),
          PaymentMethodModel(
            id: _id(),
            companyId: companyId,
            name: t('Převod', 'Bank Transfer'),
            type: PaymentType.bank,
            createdAt: now,
            updatedAt: now,
          ),
          PaymentMethodModel(
            id: _id(),
            companyId: companyId,
            name: t('Zákaznický kredit', 'Customer Credit'),
            type: PaymentType.credit,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
          PaymentMethodModel(
            id: _id(),
            companyId: companyId,
            name: t('Stravenky', 'Meal Vouchers'),
            type: PaymentType.voucher,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        ];
        for (final pm in paymentMethods) {
          await _db.into(_db.paymentMethods).insert(paymentMethodToCompanion(pm));
        }

        // 4. Default section
        await _db.into(_db.sections).insert(sectionToCompanion(
          SectionModel(id: _id(), companyId: companyId, name: t('Hlavní', 'Main'), color: '#4CAF50', isDefault: true, createdAt: now, updatedAt: now),
        ));

        // 5. Register
        final register = RegisterModel(
          id: registerId,
          companyId: companyId,
          code: 'REG-1',
          name: t('Hlavní pokladna', 'Main Register'),
          registerNumber: 1,
          isMain: true,
          type: HardwareType.local,
          allowCash: true,
          allowCard: true,
          allowTransfer: true,
          allowRefunds: false,
          gridRows: 5,
          gridCols: 8,
          createdAt: now,
          updatedAt: now,
        );
        await _db.into(_db.registers).insert(RegistersCompanion.insert(
              id: register.id,
              companyId: register.companyId,
              code: register.code,
              name: Value(register.name),
              registerNumber: Value(register.registerNumber),
              isMain: const Value(true),
              boundDeviceId: Value(deviceId),
              type: register.type,
            ));

        // 5b. Auto-bind device to the main register
        await _db.into(_db.deviceRegistrations).insert(
          DeviceRegistrationsCompanion.insert(
            id: _id(),
            companyId: companyId,
            registerId: registerId,
            createdAt: now,
          ),
        );

        // 6. Admin user
        final user = UserModel(
          id: userId,
          companyId: companyId,
          username: adminUsername,
          fullName: adminFullName,
          pinHash: PinHelper.hashPin(adminPin),
          roleId: adminRoleId,
          createdAt: now,
          updatedAt: now,
        );
        await _db.into(_db.users).insert(userToCompanion(user));

        // 7. User permissions (admin gets all permissions)
        for (final permEntity in permissionEntities) {
          final up = UserPermissionModel(
            id: _id(),
            companyId: companyId,
            userId: userId,
            permissionId: permEntity.id,
            grantedBy: userId,
            createdAt: now,
            updatedAt: now,
          );
          await _db
              .into(_db.userPermissions)
              .insert(userPermissionToCompanion(up));
        }
      });

      AppLogger.info('Onboarding seed completed for company: $companyName');
      return Success(companyId);
    } catch (e, s) {
      AppLogger.error('Onboarding seed failed', error: e, stackTrace: s);
      return Failure('Onboarding seed failed: $e');
    }
  }

  /// Seeds static demo data (categories, items, tables, suppliers, manufacturers)
  /// for non-demo companies with the "with test data" checkbox.
  Future<Result<void>> seedStaticDemoData({
    required String companyId,
    required String locale,
    required String mode,
    required String defaultTaxRateId,
  }) async {
    try {
      final now = DateTime.now();
      String t(String cs, String en) => locale == 'en' ? en : cs;

      await _db.transaction(() async {
        // --- Suppliers ---
        final supplier1Id = _id();
        final supplier2Id = _id();

        if (mode == 'gastro') {
          await _db.into(_db.suppliers).insert(supplierToCompanion(SupplierModel(
            id: supplier1Id, companyId: companyId,
            supplierName: 'Makro Cash & Carry',
            createdAt: now, updatedAt: now,
          )));
          await _db.into(_db.suppliers).insert(supplierToCompanion(SupplierModel(
            id: supplier2Id, companyId: companyId,
            supplierName: t('Nápoje s.r.o.', 'Beverage Co.'),
            createdAt: now, updatedAt: now,
          )));
        } else {
          await _db.into(_db.suppliers).insert(supplierToCompanion(SupplierModel(
            id: supplier1Id, companyId: companyId,
            supplierName: t('Velkoobchod CZ', 'Wholesale Co.'),
            createdAt: now, updatedAt: now,
          )));
          await _db.into(_db.suppliers).insert(supplierToCompanion(SupplierModel(
            id: supplier2Id, companyId: companyId,
            supplierName: t('Distribuce Plus', 'Distribution Plus'),
            createdAt: now, updatedAt: now,
          )));
        }

        // --- Manufacturers ---
        final mfr1Id = _id();
        final mfr2Id = _id();

        if (mode == 'gastro') {
          await _db.into(_db.manufacturers).insert(manufacturerToCompanion(ManufacturerModel(
            id: mfr1Id, companyId: companyId,
            name: t('Plzeňský Prazdroj', 'Pilsner Urquell'),
            createdAt: now, updatedAt: now,
          )));
          await _db.into(_db.manufacturers).insert(manufacturerToCompanion(ManufacturerModel(
            id: mfr2Id, companyId: companyId,
            name: 'Kofola',
            createdAt: now, updatedAt: now,
          )));
        } else {
          await _db.into(_db.manufacturers).insert(manufacturerToCompanion(ManufacturerModel(
            id: mfr1Id, companyId: companyId,
            name: t('Český výrobce', 'Local Producer'),
            createdAt: now, updatedAt: now,
          )));
          await _db.into(_db.manufacturers).insert(manufacturerToCompanion(ManufacturerModel(
            id: mfr2Id, companyId: companyId,
            name: t('Import s.r.o.', 'Import Ltd.'),
            createdAt: now, updatedAt: now,
          )));
        }

        // --- Categories & Items ---
        if (mode == 'gastro') {
          await _seedGastroData(companyId, now, t, defaultTaxRateId, supplier2Id, mfr1Id, mfr2Id);
        } else {
          await _seedRetailData(companyId, now, t, defaultTaxRateId, supplier1Id, mfr1Id);
        }

        // --- Tables (gastro only) ---
        if (mode == 'gastro') {
          // Get default section for tables
          final sectionEntity = await (_db.select(_db.sections)
                ..where((s) => s.companyId.equals(companyId) & s.isDefault.equals(true)))
              .getSingleOrNull();
          final sectionId = sectionEntity?.id;

          final tableNames = [
            t('Stůl 1', 'Table 1'), t('Stůl 2', 'Table 2'),
            t('Stůl 3', 'Table 3'), t('Stůl 4', 'Table 4'),
            t('Stůl 5', 'Table 5'), t('Stůl 6', 'Table 6'),
            t('Stůl 7', 'Table 7'), t('Stůl 8', 'Table 8'),
            t('Zahradní 1', 'Patio 1'), t('Zahradní 2', 'Patio 2'),
          ];
          for (final name in tableNames) {
            await _db.into(_db.tables).insert(tableToCompanion(TableModel(
              id: _id(), companyId: companyId, sectionId: sectionId,
              name: name, capacity: 4, shape: TableShape.rectangle,
              createdAt: now, updatedAt: now,
            )));
          }
        }
      });

      AppLogger.info('Static demo data seeded for company: $companyId (mode: $mode)');
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Static demo data seed failed', error: e, stackTrace: s);
      return Failure('Static demo data seed failed: $e');
    }
  }

  Future<void> _seedGastroData(
    String companyId, DateTime now, String Function(String, String) t,
    String taxRateId, String supplierId, String mfr1Id, String mfr2Id,
  ) async {
    // Categories
    final catMain = _id();
    final catStarters = _id();
    final catDesserts = _id();
    final catSoftDrinks = _id();
    final catBeer = _id();
    final catWine = _id();
    final catOther = _id();

    final categories = [
      CategoryModel(id: catMain, companyId: companyId, name: t('Hlavní jídla', 'Main Courses'), createdAt: now, updatedAt: now),
      CategoryModel(id: catStarters, companyId: companyId, name: t('Předkrmy', 'Starters'), createdAt: now, updatedAt: now),
      CategoryModel(id: catDesserts, companyId: companyId, name: t('Dezerty', 'Desserts'), createdAt: now, updatedAt: now),
      CategoryModel(id: catSoftDrinks, companyId: companyId, name: t('Nealko', 'Soft Drinks'), createdAt: now, updatedAt: now),
      CategoryModel(id: catBeer, companyId: companyId, name: t('Pivo', 'Beer'), createdAt: now, updatedAt: now),
      CategoryModel(id: catWine, companyId: companyId, name: t('Víno', 'Wine'), createdAt: now, updatedAt: now),
      CategoryModel(id: catOther, companyId: companyId, name: t('Ostatní', 'Other'), createdAt: now, updatedAt: now),
    ];
    for (final c in categories) {
      await _db.into(_db.categories).insert(categoryToCompanion(c));
    }

    // Items
    final items = [
      // Main courses
      ItemModel(id: _id(), companyId: companyId, categoryId: catMain, name: t('Svíčková na smetaně', 'Beef sirloin in cream sauce'), itemType: ItemType.product, unitPrice: 28900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catMain, name: t('Kuřecí řízek', 'Chicken schnitzel'), itemType: ItemType.product, unitPrice: 22900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catMain, name: t('Grilovaný losos', 'Grilled salmon'), itemType: ItemType.product, unitPrice: 34900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catMain, name: t('Hovězí burger', 'Beef burger'), itemType: ItemType.product, unitPrice: 25900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      // Starters
      ItemModel(id: _id(), companyId: companyId, categoryId: catStarters, name: t('Česneková polévka', 'Garlic soup'), itemType: ItemType.product, unitPrice: 8900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catStarters, name: t('Caprese salát', 'Caprese salad'), itemType: ItemType.product, unitPrice: 14900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      // Desserts
      ItemModel(id: _id(), companyId: companyId, categoryId: catDesserts, name: t('Palačinky', 'Pancakes'), itemType: ItemType.product, unitPrice: 11900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catDesserts, name: t('Čokoládový fondant', 'Chocolate fondant'), itemType: ItemType.product, unitPrice: 15900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      // Soft drinks
      ItemModel(id: _id(), companyId: companyId, categoryId: catSoftDrinks, name: 'Coca-Cola 0.33l', itemType: ItemType.product, unitPrice: 4900, saleTaxRateId: taxRateId, unit: UnitType.ks, supplierId: supplierId, manufacturerId: mfr2Id, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catSoftDrinks, name: t('Minerální voda 0.33l', 'Mineral water 0.33l'), itemType: ItemType.product, unitPrice: 3900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catSoftDrinks, name: t('Džus pomeranč 0.2l', 'Orange juice 0.2l'), itemType: ItemType.product, unitPrice: 4500, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      // Beer
      ItemModel(id: _id(), companyId: companyId, categoryId: catBeer, name: 'Pilsner Urquell 0.5l', itemType: ItemType.product, unitPrice: 5900, saleTaxRateId: taxRateId, unit: UnitType.ks, supplierId: supplierId, manufacturerId: mfr1Id, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catBeer, name: t('Kozel 11° 0.5l', 'Kozel Lager 0.5l'), itemType: ItemType.product, unitPrice: 4900, saleTaxRateId: taxRateId, unit: UnitType.ks, supplierId: supplierId, manufacturerId: mfr1Id, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catBeer, name: t('Nealkoholické pivo', 'Non-alcoholic beer'), itemType: ItemType.product, unitPrice: 4500, saleTaxRateId: taxRateId, unit: UnitType.ks, manufacturerId: mfr1Id, createdAt: now, updatedAt: now),
      // Wine
      ItemModel(id: _id(), companyId: companyId, categoryId: catWine, name: t('Rulandské šedé 0.2l', 'Pinot Gris 0.2l'), itemType: ItemType.product, unitPrice: 6900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catWine, name: t('Frankovka 0.2l', 'Blaufränkisch 0.2l'), itemType: ItemType.product, unitPrice: 5900, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      // Other
      ItemModel(id: _id(), companyId: companyId, categoryId: catOther, name: t('Espresso', 'Espresso'), itemType: ItemType.product, unitPrice: 5500, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catOther, name: t('Cappuccino', 'Cappuccino'), itemType: ItemType.product, unitPrice: 6500, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
    ];
    for (final item in items) {
      await _db.into(_db.items).insert(itemToCompanion(item));
    }
  }

  Future<void> _seedRetailData(
    String companyId, DateTime now, String Function(String, String) t,
    String taxRateId, String supplierId, String mfrId,
  ) async {
    // Categories
    final catFood = _id();
    final catDrinks = _id();
    final catDrogerie = _id();
    final catHome = _id();
    final catOther = _id();

    final categories = [
      CategoryModel(id: catFood, companyId: companyId, name: t('Potraviny', 'Food'), createdAt: now, updatedAt: now),
      CategoryModel(id: catDrinks, companyId: companyId, name: t('Nápoje', 'Beverages'), createdAt: now, updatedAt: now),
      CategoryModel(id: catDrogerie, companyId: companyId, name: t('Drogerie', 'Drugstore'), createdAt: now, updatedAt: now),
      CategoryModel(id: catHome, companyId: companyId, name: t('Domácnost', 'Household'), createdAt: now, updatedAt: now),
      CategoryModel(id: catOther, companyId: companyId, name: t('Ostatní', 'Other'), createdAt: now, updatedAt: now),
    ];
    for (final c in categories) {
      await _db.into(_db.categories).insert(categoryToCompanion(c));
    }

    // Items
    final items = [
      // Food
      ItemModel(id: _id(), companyId: companyId, categoryId: catFood, name: t('Rohlík', 'Bread roll'), itemType: ItemType.product, unitPrice: 400, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000001', supplierId: supplierId, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catFood, name: t('Chleba krajíc', 'Sliced bread'), itemType: ItemType.product, unitPrice: 3200, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000002', supplierId: supplierId, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catFood, name: t('Máslo 250g', 'Butter 250g'), itemType: ItemType.product, unitPrice: 5990, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000003', createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catFood, name: t('Mléko 1l', 'Milk 1l'), itemType: ItemType.product, unitPrice: 2490, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000004', createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catFood, name: t('Šunka 100g', 'Ham 100g'), itemType: ItemType.product, unitPrice: 3990, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catFood, name: t('Sýr Eidam 100g', 'Edam cheese 100g'), itemType: ItemType.product, unitPrice: 2990, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      // Beverages
      ItemModel(id: _id(), companyId: companyId, categoryId: catDrinks, name: 'Coca-Cola 1.5l', itemType: ItemType.product, unitPrice: 3990, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000010', createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catDrinks, name: t('Minerální voda 1.5l', 'Mineral water 1.5l'), itemType: ItemType.product, unitPrice: 1990, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000011', createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catDrinks, name: t('Pivo 0.5l plechovka', 'Beer 0.5l can'), itemType: ItemType.product, unitPrice: 2490, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000012', manufacturerId: mfrId, createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catDrinks, name: t('Džus 1l', 'Juice 1l'), itemType: ItemType.product, unitPrice: 4990, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      // Drugstore
      ItemModel(id: _id(), companyId: companyId, categoryId: catDrogerie, name: t('Zubní pasta', 'Toothpaste'), itemType: ItemType.product, unitPrice: 6990, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000020', createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catDrogerie, name: t('Mýdlo', 'Soap'), itemType: ItemType.product, unitPrice: 2990, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000021', createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catDrogerie, name: t('Šampon', 'Shampoo'), itemType: ItemType.product, unitPrice: 8990, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      // Household
      ItemModel(id: _id(), companyId: companyId, categoryId: catHome, name: t('Papírové utěrky', 'Paper towels'), itemType: ItemType.product, unitPrice: 4990, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000030', createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catHome, name: t('Odpadkové pytle', 'Trash bags'), itemType: ItemType.product, unitPrice: 5990, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
      // Other
      ItemModel(id: _id(), companyId: companyId, categoryId: catOther, name: t('Baterie AA 4ks', 'AA Batteries 4-pack'), itemType: ItemType.product, unitPrice: 7990, saleTaxRateId: taxRateId, unit: UnitType.ks, sku: '8590000000040', createdAt: now, updatedAt: now),
      ItemModel(id: _id(), companyId: companyId, categoryId: catOther, name: t('Igelitová taška', 'Plastic bag'), itemType: ItemType.product, unitPrice: 500, saleTaxRateId: taxRateId, unit: UnitType.ks, createdAt: now, updatedAt: now),
    ];
    for (final item in items) {
      await _db.into(_db.items).insert(itemToCompanion(item));
    }
  }
}

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../auth/pin_helper.dart';
import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/company_status.dart';
import '../enums/hardware_type.dart';
import '../enums/item_type.dart';
import '../enums/layout_item_type.dart';
import '../enums/payment_type.dart';
import '../enums/role_name.dart';
import '../enums/tax_calc_type.dart';
import '../enums/table_shape.dart';
import '../enums/unit_type.dart';
import '../mappers/entity_mappers.dart';
import '../models/category_model.dart';
import '../models/company_model.dart';
import '../models/company_settings_model.dart';
import '../models/customer_model.dart';
import '../models/item_model.dart';
import '../models/item_modifier_group_model.dart';
import '../models/manufacturer_model.dart';
import '../models/modifier_group_item_model.dart';
import '../models/modifier_group_model.dart';
import '../models/map_element_model.dart';
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

  Future<Result<String>> seedOnboarding({
    required String companyName,
    String? businessId,
    String? address,
    String? email,
    String? phone,
    required String adminFullName,
    required String adminUsername,
    required String adminPin,
    bool withTestData = false,
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
        // ── ESSENTIALS (always) ──

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
        final taxRate21Id = _id();
        final taxRate12Id = _id();
        final taxRates = [
          TaxRateModel(
            id: taxRate21Id,
            companyId: companyId,
            label: t('Základní 21%', 'Standard 21%'),
            type: TaxCalcType.regular,
            rate: 2100,
            isDefault: true,
            createdAt: now,
            updatedAt: now,
          ),
          TaxRateModel(
            id: taxRate12Id,
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

        // 4. Sections — always create Hlavní, demo adds Zahrádka + Interní
        final hlavniId = _id();
        await _db.into(_db.sections).insert(sectionToCompanion(
          SectionModel(id: hlavniId, companyId: companyId, name: t('Hlavní', 'Main'), color: '#4CAF50', isDefault: true, createdAt: now, updatedAt: now),
        ));

        String? zahradkaId;
        String? interniId;

        if (withTestData) {
          zahradkaId = _id();
          interniId = _id();
          final demoSections = [
            SectionModel(id: zahradkaId, companyId: companyId, name: t('Zahrádka', 'Garden'), color: '#FF9800', createdAt: now, updatedAt: now),
            SectionModel(id: interniId, companyId: companyId, name: t('Interní', 'Internal'), color: '#9E9E9E', createdAt: now, updatedAt: now),
          ];
          for (final s in demoSections) {
            await _db.into(_db.sections).insert(sectionToCompanion(s));
          }
        }

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

        // ── DEMO DATA (only with withTestData) ──

        if (withTestData) {
          // 8. Tables — Hlavní & Zahrádka placed on floor map, Interní off-map
          final tables = [
            // Hlavní section — floor map layout
            TableModel(id: _id(), companyId: companyId, name: t('Stůl 1', 'Table 1'), sectionId: hlavniId, capacity: 4, gridRow: 1, gridCol: 1, gridWidth: 4, gridHeight: 4, shape: TableShape.round, fontSize: 14, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Stůl 2', 'Table 2'), sectionId: hlavniId, capacity: 4, gridRow: 7, gridCol: 1, gridWidth: 4, gridHeight: 4, shape: TableShape.round, fontSize: 14, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Stůl 3', 'Table 3'), sectionId: hlavniId, capacity: 4, gridRow: 13, gridCol: 1, gridWidth: 4, gridHeight: 4, shape: TableShape.round, fontSize: 14, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Stůl 4', 'Table 4'), sectionId: hlavniId, capacity: 4, gridRow: 1, gridCol: 9, gridWidth: 4, gridHeight: 4, shape: TableShape.diamond, fontSize: 14, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Stůl 5', 'Table 5'), sectionId: hlavniId, capacity: 4, gridRow: 1, gridCol: 17, gridWidth: 4, gridHeight: 4, shape: TableShape.diamond, fontSize: 14, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Stůl 6', 'Table 6'), sectionId: hlavniId, gridRow: 1, gridCol: 25, gridWidth: 4, gridHeight: 4, shape: TableShape.diamond, fontSize: 14, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: 'Bar 1', sectionId: hlavniId, gridRow: 8, gridCol: 22, gridWidth: 2, gridHeight: 2, color: '#4CAF50', fontSize: 14, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Stůl 7', 'Table 7'), sectionId: hlavniId, gridRow: 10, gridCol: 10, gridWidth: 7, gridHeight: 4, fontSize: 14, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: 'Bar 2', sectionId: hlavniId, gridRow: 11, gridCol: 22, gridWidth: 2, gridHeight: 2, fontSize: 14, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: 'Bar 3', sectionId: hlavniId, gridRow: 14, gridCol: 22, gridWidth: 2, gridHeight: 2, fontSize: 14, createdAt: now, updatedAt: now),
            // Zahrádka section — smaller tables (2×2) in the bottom area
            TableModel(id: _id(), companyId: companyId, name: t('Stolek 1', 'Table 1'), sectionId: zahradkaId, capacity: 2, gridRow: 14, gridCol: 2, gridWidth: 2, gridHeight: 2, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Stolek 2', 'Table 2'), sectionId: zahradkaId, capacity: 2, gridRow: 14, gridCol: 8, gridWidth: 2, gridHeight: 2, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Stolek 3', 'Table 3'), sectionId: zahradkaId, capacity: 2, gridRow: 14, gridCol: 14, gridWidth: 2, gridHeight: 2, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Stolek 4', 'Table 4'), sectionId: zahradkaId, capacity: 2, gridRow: 14, gridCol: 20, gridWidth: 2, gridHeight: 2, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Stolek 5', 'Table 5'), sectionId: zahradkaId, capacity: 2, gridRow: 14, gridCol: 26, gridWidth: 2, gridHeight: 2, createdAt: now, updatedAt: now),
            // Interní section — off-map (gridRow: -1)
            TableModel(id: _id(), companyId: companyId, name: t('Majitel', 'Owner'), sectionId: interniId, capacity: 0, gridRow: -1, gridCol: -1, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Repre', 'Entertainment'), sectionId: interniId, capacity: 0, gridRow: -1, gridCol: -1, createdAt: now, updatedAt: now),
            TableModel(id: _id(), companyId: companyId, name: t('Odpisy', 'Write-offs'), sectionId: interniId, capacity: 0, gridRow: -1, gridCol: -1, createdAt: now, updatedAt: now),
          ];
          for (final t in tables) {
            await _db.into(_db.tables).insert(tableToCompanion(t));
          }

          // 8b. Map elements — Hlavní section floor map decorations
          final mapElements = [
            MapElementModel(id: _id(), companyId: companyId, sectionId: hlavniId, gridRow: 0, gridCol: 6, gridWidth: 1, gridHeight: 11, color: '#000000', fillStyle: 1, borderStyle: 1, createdAt: now, updatedAt: now),
            MapElementModel(id: _id(), companyId: companyId, sectionId: hlavniId, gridRow: 7, gridCol: 24, gridWidth: 2, gridHeight: 11, label: 'BAR', color: '#795548', fillStyle: 2, borderStyle: 2, createdAt: now, updatedAt: now),
            MapElementModel(id: _id(), companyId: companyId, sectionId: hlavniId, gridRow: 7, gridCol: 24, gridWidth: 6, gridHeight: 2, color: '#795548', fillStyle: 2, borderStyle: 2, createdAt: now, updatedAt: now),
            MapElementModel(id: _id(), companyId: companyId, sectionId: hlavniId, gridRow: 11, gridCol: 23, gridWidth: 2, gridHeight: 2, createdAt: now, updatedAt: now),
            MapElementModel(id: _id(), companyId: companyId, sectionId: hlavniId, gridRow: 12, gridCol: 12, gridWidth: 8, gridHeight: 5, createdAt: now, updatedAt: now),
            MapElementModel(id: _id(), companyId: companyId, sectionId: hlavniId, gridRow: 13, gridCol: 6, gridWidth: 1, gridHeight: 7, color: '#000000', createdAt: now, updatedAt: now),
            MapElementModel(id: _id(), companyId: companyId, sectionId: hlavniId, gridRow: 17, gridCol: 6, gridWidth: 2, gridHeight: 2, createdAt: now, updatedAt: now),
            MapElementModel(id: _id(), companyId: companyId, sectionId: hlavniId, gridRow: 19, gridCol: 11, gridWidth: 9, gridHeight: 1, label: 'EXIT', fontSize: 20, fillStyle: 2, borderStyle: 2, createdAt: now, updatedAt: now),
          ];
          for (final e in mapElements) {
            await _db.into(_db.mapElements).insert(mapElementToCompanion(e));
          }

          // 9. Suppliers & Manufacturers (IDs needed by items below)
          final supplierMakroId = _id();
          final supplierNapojeId = _id();
          final suppliers = [
            SupplierModel(
              id: supplierMakroId,
              companyId: companyId,
              supplierName: 'Makro Cash & Carry',
              contactPerson: 'Jan Novák',
              email: 'objednavky@makro.cz',
              phone: '+420 601 111 222',
              createdAt: now,
              updatedAt: now,
            ),
            SupplierModel(
              id: supplierNapojeId,
              companyId: companyId,
              supplierName: 'Nápoje Express a.s.',
              contactPerson: 'Petra Dvořáková',
              email: 'info@napoje-express.cz',
              phone: '+420 602 333 444',
              createdAt: now,
              updatedAt: now,
            ),
          ];
          for (final s in suppliers) {
            await _db.into(_db.suppliers).insert(supplierToCompanion(s));
          }

          final mfrPrazdrojId = _id();
          final mfrKofolaId = _id();
          final manufacturers = [
            ManufacturerModel(id: mfrPrazdrojId, companyId: companyId, name: 'Plzeňský Prazdroj', createdAt: now, updatedAt: now),
            ManufacturerModel(id: mfrKofolaId, companyId: companyId, name: 'Kofola ČeskoSlovensko', createdAt: now, updatedAt: now),
          ];
          for (final m in manufacturers) {
            await _db.into(_db.manufacturers).insert(manufacturerToCompanion(m));
          }

          // 10. Categories
          final catNapoje = _id();
          final catPivo = _id();
          final catHlavniJidla = _id();
          final catPredkrmy = _id();
          final catDeserty = _id();
          final catSuroviny = _id();
          final catSluzby = _id();
          final categories = [
            CategoryModel(id: catNapoje, companyId: companyId, name: t('Nápoje', 'Beverages'), createdAt: now, updatedAt: now),
            CategoryModel(id: catPivo, companyId: companyId, name: t('Pivo', 'Beer'), createdAt: now, updatedAt: now),
            CategoryModel(id: catHlavniJidla, companyId: companyId, name: t('Hlavní jídla', 'Main Courses'), createdAt: now, updatedAt: now),
            CategoryModel(id: catPredkrmy, companyId: companyId, name: t('Předkrmy', 'Starters'), createdAt: now, updatedAt: now),
            CategoryModel(id: catDeserty, companyId: companyId, name: t('Dezerty', 'Desserts'), createdAt: now, updatedAt: now),
            CategoryModel(id: catSuroviny, companyId: companyId, name: t('Suroviny', 'Ingredients'), createdAt: now, updatedAt: now),
            CategoryModel(id: catSluzby, companyId: companyId, name: t('Služby', 'Services'), createdAt: now, updatedAt: now),
          ];
          for (final c in categories) {
            await _db.into(_db.categories).insert(categoryToCompanion(c));
          }

          // 11. Items — all ItemType variants, realistic SKU/prices/relations
          final sellableByCategory = <String, List<String>>{};

          Future<void> ins(ItemModel item) async {
            await _db.into(_db.items).insert(itemToCompanion(item));
            // Only place sellable non-variant/modifier items on the grid
            if (item.isSellable &&
                item.categoryId != null &&
                item.itemType != ItemType.variant &&
                item.itemType != ItemType.modifier) {
              sellableByCategory
                  .putIfAbsent(item.categoryId!, () => [])
                  .add(item.id);
            }
          }

          // ── Nápoje (12% — nealkoholické) ──
          // Stocked from supplier, some with manufacturer
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Coca-Cola 0.33l', itemType: ItemType.product, sku: 'NAP-001', altSku: '5449000000996', unitPrice: 4900, purchasePrice: 2200, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: t('Mattoni neperlivá 0.33l', 'Mattoni Still 0.33l'), itemType: ItemType.product, sku: 'NAP-002', unitPrice: 3900, purchasePrice: 1200, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: t('Džus pomerančový 0.2l', 'Orange Juice 0.2l'), itemType: ItemType.product, sku: 'NAP-003', unitPrice: 4500, purchasePrice: 1800, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Kofola Original 0.5l', itemType: ItemType.product, sku: 'NAP-004', altSku: '8593868001019', unitPrice: 4500, purchasePrice: 1800, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, manufacturerId: mfrKofolaId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: t('Rajec jemně perlivá 0.33l', 'Rajec Sparkling 0.33l'), itemType: ItemType.product, sku: 'NAP-005', unitPrice: 3900, purchasePrice: 1100, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, manufacturerId: mfrKofolaId, createdAt: now, updatedAt: now));
          // In-house drinks — no supplier, no purchase price, no stock tracking
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Espresso', itemType: ItemType.product, sku: 'NAP-006', unitPrice: 5500, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Cappuccino', itemType: ItemType.product, sku: 'NAP-007', unitPrice: 6500, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: t('Čaj (výběr)', 'Tea (selection)'), itemType: ItemType.product, sku: 'NAP-008', unitPrice: 4500, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: t('Domácí limonáda 0.4l', 'Homemade Lemonade 0.4l'), itemType: ItemType.product, sku: 'NAP-009', unitPrice: 6900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));

          // ── Pivo (21% — alkohol) ──
          // All stocked, from Nápoje Express, brewery as manufacturer
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPivo, name: 'Pilsner Urquell 0.5l', itemType: ItemType.product, sku: 'PIV-001', altSku: '8594404000015', unitPrice: 5900, purchasePrice: 2500, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, manufacturerId: mfrPrazdrojId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPivo, name: 'Kozel 11° 0.5l', itemType: ItemType.product, sku: 'PIV-002', unitPrice: 4900, purchasePrice: 2000, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, manufacturerId: mfrPrazdrojId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPivo, name: 'Gambrinus 10° 0.5l', itemType: ItemType.product, sku: 'PIV-003', unitPrice: 3900, purchasePrice: 1600, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, manufacturerId: mfrPrazdrojId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPivo, name: 'Bernard 12° 0.5l', itemType: ItemType.product, sku: 'PIV-004', unitPrice: 5500, purchasePrice: 2400, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPivo, name: 'Staropramen 11° 0.5l', itemType: ItemType.product, sku: 'PIV-005', unitPrice: 4500, purchasePrice: 1900, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, createdAt: now, updatedAt: now));
          // Non-alcoholic beer — 12% tax (unlike regular beer!)
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPivo, name: 'Birell Pomelo 0.5l', itemType: ItemType.product, sku: 'PIV-006', unitPrice: 4500, purchasePrice: 2000, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, manufacturerId: mfrPrazdrojId, createdAt: now, updatedAt: now));

          // ── Hlavní jídla (12%, in-house — no supplier/manufacturer) ──
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: t('Svíčková na smetaně', 'Beef Sirloin in Cream Sauce'), itemType: ItemType.product, sku: 'HJ-001', unitPrice: 22900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: t('Řízek s bramborovým salátem', 'Schnitzel with Potato Salad'), itemType: ItemType.product, sku: 'HJ-002', unitPrice: 19900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: t('Grilovaný losos', 'Grilled Salmon'), itemType: ItemType.product, sku: 'HJ-003', unitPrice: 27900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: t('Kuřecí steak s hranolky', 'Chicken Steak with Fries'), itemType: ItemType.product, sku: 'HJ-004', unitPrice: 18900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          // Recipe — composite (assembled from ingredients)
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: t('Smažený sýr s hranolky', 'Fried Cheese with Fries'), itemType: ItemType.recipe, sku: 'HJ-005', unitPrice: 17900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          // Parent product with variants
          final burgerParentId = _id();
          await ins(ItemModel(id: burgerParentId, companyId: companyId, categoryId: catHlavniJidla, name: t('Hovězí burger', 'Beef Burger'), itemType: ItemType.product, sku: 'HJ-006', unitPrice: 21900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: t('Burger – klasický', 'Burger – Classic'), itemType: ItemType.variant, sku: 'HJ-006-KLA', unitPrice: 21900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, parentId: burgerParentId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: t('Burger – double', 'Burger – Double'), itemType: ItemType.variant, sku: 'HJ-006-DBL', unitPrice: 25900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, parentId: burgerParentId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: t('Burger – vegetariánský', 'Burger – Vegetarian'), itemType: ItemType.variant, sku: 'HJ-006-VEG', unitPrice: 18900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, parentId: burgerParentId, createdAt: now, updatedAt: now));
          // Modifiers (no category, no SKU — add-ons across menu)
          final modExtraSyrId = _id();
          final modExtraSlaId = _id();
          final modHranolkyId = _id();
          final modKecupId = _id();
          final modMajonezaId = _id();
          final modBbqId = _id();
          final modSalatId = _id();
          await ins(ItemModel(id: modExtraSyrId, companyId: companyId, name: t('Extra sýr', 'Extra Cheese'), itemType: ItemType.modifier, unitPrice: 2900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: modExtraSlaId, companyId: companyId, name: t('Extra slanina', 'Extra Bacon'), itemType: ItemType.modifier, unitPrice: 3900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: modHranolkyId, companyId: companyId, name: t('Příloha hranolky', 'Side Fries'), itemType: ItemType.modifier, unitPrice: 4900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: modKecupId, companyId: companyId, name: t('Kečup', 'Ketchup'), itemType: ItemType.modifier, unitPrice: 0, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: modMajonezaId, companyId: companyId, name: t('Majonéza', 'Mayonnaise'), itemType: ItemType.modifier, unitPrice: 0, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: modBbqId, companyId: companyId, name: t('BBQ omáčka', 'BBQ Sauce'), itemType: ItemType.modifier, unitPrice: 1500, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: modSalatId, companyId: companyId, name: t('Salát', 'Salad'), itemType: ItemType.modifier, unitPrice: 3900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));

          // ── Předkrmy (12%) ──
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: t('Tatarský biftek', 'Beef Tartare'), itemType: ItemType.product, sku: 'PK-001', unitPrice: 18900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: t('Carpaccio z hovězího', 'Beef Carpaccio'), itemType: ItemType.product, sku: 'PK-002', unitPrice: 16900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: 'Bruschetta', itemType: ItemType.product, sku: 'PK-003', unitPrice: 12900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: t('Polévka dne', 'Soup of the Day'), itemType: ItemType.product, sku: 'PK-004', unitPrice: 6900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: t('Caesar salát', 'Caesar Salad'), itemType: ItemType.product, sku: 'PK-005', unitPrice: 14900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));

          // ── Dezerty (12%) ──
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: 'Tiramisu', itemType: ItemType.product, sku: 'DES-001', unitPrice: 11900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: t('Čokoládový fondant', 'Chocolate Fondant'), itemType: ItemType.product, sku: 'DES-002', unitPrice: 13900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: t('Palačinky s Nutellou', 'Nutella Pancakes'), itemType: ItemType.product, sku: 'DES-003', unitPrice: 10900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: t('Zmrzlinový pohár', 'Ice Cream Sundae'), itemType: ItemType.product, sku: 'DES-004', unitPrice: 9900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: t('Jablečný štrúdl', 'Apple Strudel'), itemType: ItemType.product, sku: 'DES-005', unitPrice: 8900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));

          // ── Suroviny / Ingredients (12%, not sellable, stock tracked, from Makro) ──
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: t('Kuřecí prsa', 'Chicken Breast'), itemType: ItemType.ingredient, sku: 'SUR-001', unitPrice: 18900, purchasePrice: 18900, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.kg, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: t('Hovězí svíčková', 'Beef Sirloin'), itemType: ItemType.ingredient, sku: 'SUR-002', unitPrice: 34900, purchasePrice: 34900, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.g, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: t('Mouka hladká', 'Plain Flour'), itemType: ItemType.ingredient, sku: 'SUR-003', unitPrice: 2900, purchasePrice: 2900, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.kg, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: t('Smetana 33%', 'Heavy Cream 33%'), itemType: ItemType.ingredient, sku: 'SUR-004', unitPrice: 6900, purchasePrice: 6900, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.l, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: t('Eidam 30%', 'Edam Cheese 30%'), itemType: ItemType.ingredient, sku: 'SUR-005', unitPrice: 15900, purchasePrice: 15900, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.g, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));

          // ── Counter / Spotřební materiál (21%, not sellable, stock tracked, from Makro) ──
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: t('Ubrousek', 'Napkin'), itemType: ItemType.counter, sku: 'SPT-001', unitPrice: 100, purchasePrice: 50, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: t('Kelímek na odnos', 'Takeaway Cup'), itemType: ItemType.counter, sku: 'SPT-002', unitPrice: 500, purchasePrice: 250, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: t('Papírový tácek', 'Paper Tray'), itemType: ItemType.counter, sku: 'SPT-003', unitPrice: 200, purchasePrice: 100, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));

          // ── Služby / Services (21%, no stock) ──
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSluzby, name: t('Pronájem sálu (hodina)', 'Hall Rental (hour)'), itemType: ItemType.service, sku: 'SLU-001', unitPrice: 150000, saleTaxRateId: taxRate21Id, unit: UnitType.h, createdAt: now, updatedAt: now));
          await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSluzby, name: t('Raut – obsluha (osoba)', 'Catering – Staff (person)'), itemType: ItemType.service, sku: 'SLU-002', unitPrice: 50000, saleTaxRateId: taxRate21Id, unit: UnitType.ks, createdAt: now, updatedAt: now));

          // 12. Layout items for sell grid (horizontal — matches auto-arrange)
          final gridRows = 5;
          final gridCols = 8;
          final categoryIds = [catNapoje, catPivo, catHlavniJidla,
              catPredkrmy, catDeserty, catSuroviny, catSluzby];
          int pageCounter = 1;

          for (var catIdx = 0;
              catIdx < categoryIds.length && catIdx < gridRows;
              catIdx++) {
            final catId = categoryIds[catIdx];
            final catItems = sellableByCategory[catId] ?? [];

            // Page 0: category at (catIdx, 0)
            await _db.into(_db.layoutItems).insert(LayoutItemsCompanion.insert(
              id: _id(),
              companyId: companyId,
              registerId: registerId,
              page: const Value(0),
              gridRow: catIdx,
              gridCol: 0,
              type: LayoutItemType.category,
              categoryId: Value(catId),
            ));

            // Page 0: items at (catIdx, 1..gridCols-1)
            for (var c = 1; c < gridCols && c - 1 < catItems.length; c++) {
              await _db
                  .into(_db.layoutItems)
                  .insert(LayoutItemsCompanion.insert(
                    id: _id(),
                    companyId: companyId,
                    registerId: registerId,
                    page: const Value(0),
                    gridRow: catIdx,
                    gridCol: c,
                    type: LayoutItemType.item,
                    itemId: Value(catItems[c - 1]),
                  ));
            }

            // Sub-page: category marker at (0, 0) + all items
            if (catItems.isNotEmpty) {
              final page = pageCounter++;
              await _db
                  .into(_db.layoutItems)
                  .insert(LayoutItemsCompanion.insert(
                    id: _id(),
                    companyId: companyId,
                    registerId: registerId,
                    page: Value(page),
                    gridRow: 0,
                    gridCol: 0,
                    type: LayoutItemType.category,
                    categoryId: Value(catId),
                  ));

              // Items left-to-right, top-to-bottom (skip (0,0))
              var idx = 0;
              for (var r = 0;
                  r < gridRows && idx < catItems.length;
                  r++) {
                final startCol = r == 0 ? 1 : 0;
                for (var c = startCol;
                    c < gridCols && idx < catItems.length;
                    c++) {
                  await _db
                      .into(_db.layoutItems)
                      .insert(LayoutItemsCompanion.insert(
                        id: _id(),
                        companyId: companyId,
                        registerId: registerId,
                        page: Value(page),
                        gridRow: r,
                        gridCol: c,
                        type: LayoutItemType.item,
                        itemId: Value(catItems[idx]),
                      ));
                  idx++;
                }
              }
            }
          }

          // 13. Customers (varying completeness for testing)
          final customers = [
            // Frequent guest — has everything, recent visit, points, spending history
            CustomerModel(id: _id(), companyId: companyId, firstName: 'Martin', lastName: 'Svoboda', email: 'martin.svoboda@email.cz', phone: '+420 777 111 222', points: 120, totalSpent: 458000, lastVisitDate: now.subtract(const Duration(days: 3)), createdAt: now, updatedAt: now),
            // Regular — has credit (prepaid), email + phone
            CustomerModel(id: _id(), companyId: companyId, firstName: 'Lucie', lastName: 'Černá', email: 'lucie.cerna@email.cz', phone: '+420 777 333 444', points: 85, credit: 20000, totalSpent: 234500, lastVisitDate: now.subtract(const Duration(days: 7)), createdAt: now, updatedAt: now),
            // New customer — minimal data, phone only
            CustomerModel(id: _id(), companyId: companyId, firstName: 'Tomáš', lastName: 'Krejčí', phone: '+420 608 555 666', createdAt: now, updatedAt: now),
            // Company customer — email + address, high spending, no phone
            CustomerModel(id: _id(), companyId: companyId, firstName: 'Eva', lastName: 'Nováková', email: 'eva.novakova@firma.cz', address: 'Dlouhá 15, Praha 1', totalSpent: 1250000, lastVisitDate: now.subtract(const Duration(days: 14)), createdAt: now, updatedAt: now),
            // Customer with birthdate — phone + address, no email
            CustomerModel(id: _id(), companyId: companyId, firstName: 'Petr', lastName: 'Veselý', phone: '+420 603 777 888', address: 'Náměstí Míru 8, Brno', birthdate: DateTime(1985, 6, 15), points: 45, totalSpent: 89000, lastVisitDate: now.subtract(const Duration(days: 30)), createdAt: now, updatedAt: now),
          ];
          for (final c in customers) {
            await _db.into(_db.customers).insert(customerToCompanion(c));
          }

          // 14. Modifier groups
          final mgPrilohyId = _id();
          final mgExtraId = _id();
          final mgOmackyId = _id();
          final modifierGroups = [
            ModifierGroupModel(id: mgPrilohyId, companyId: companyId, name: t('Přílohy', 'Side Dishes'), minSelections: 0, maxSelections: 1, sortOrder: 0, createdAt: now, updatedAt: now),
            ModifierGroupModel(id: mgExtraId, companyId: companyId, name: t('Extra ingredience', 'Extra Ingredients'), minSelections: 0, sortOrder: 1, createdAt: now, updatedAt: now),
            ModifierGroupModel(id: mgOmackyId, companyId: companyId, name: t('Omáčky', 'Sauces'), minSelections: 0, maxSelections: 2, sortOrder: 2, createdAt: now, updatedAt: now),
          ];
          for (final mg in modifierGroups) {
            await _db.into(_db.modifierGroups).insert(modifierGroupToCompanion(mg));
          }

          // 15. Modifier group items — assign modifier items to groups
          final modifierGroupItems = [
            // Přílohy: Hranolky (default), Salát
            ModifierGroupItemModel(id: _id(), companyId: companyId, modifierGroupId: mgPrilohyId, itemId: modHranolkyId, sortOrder: 0, isDefault: true, createdAt: now, updatedAt: now),
            ModifierGroupItemModel(id: _id(), companyId: companyId, modifierGroupId: mgPrilohyId, itemId: modSalatId, sortOrder: 1, createdAt: now, updatedAt: now),
            // Extra ingredience: Extra sýr, Extra slanina
            ModifierGroupItemModel(id: _id(), companyId: companyId, modifierGroupId: mgExtraId, itemId: modExtraSyrId, sortOrder: 0, createdAt: now, updatedAt: now),
            ModifierGroupItemModel(id: _id(), companyId: companyId, modifierGroupId: mgExtraId, itemId: modExtraSlaId, sortOrder: 1, createdAt: now, updatedAt: now),
            // Omáčky: Kečup, Majonéza, BBQ
            ModifierGroupItemModel(id: _id(), companyId: companyId, modifierGroupId: mgOmackyId, itemId: modKecupId, sortOrder: 0, createdAt: now, updatedAt: now),
            ModifierGroupItemModel(id: _id(), companyId: companyId, modifierGroupId: mgOmackyId, itemId: modMajonezaId, sortOrder: 1, createdAt: now, updatedAt: now),
            ModifierGroupItemModel(id: _id(), companyId: companyId, modifierGroupId: mgOmackyId, itemId: modBbqId, sortOrder: 2, createdAt: now, updatedAt: now),
          ];
          for (final mgi in modifierGroupItems) {
            await _db.into(_db.modifierGroupItems).insert(modifierGroupItemToCompanion(mgi));
          }

          // 16. Item modifier groups — assign modifier groups to burger
          final itemModifierGroups = [
            ItemModifierGroupModel(id: _id(), companyId: companyId, itemId: burgerParentId, modifierGroupId: mgPrilohyId, sortOrder: 0, createdAt: now, updatedAt: now),
            ItemModifierGroupModel(id: _id(), companyId: companyId, itemId: burgerParentId, modifierGroupId: mgExtraId, sortOrder: 1, createdAt: now, updatedAt: now),
            ItemModifierGroupModel(id: _id(), companyId: companyId, itemId: burgerParentId, modifierGroupId: mgOmackyId, sortOrder: 2, createdAt: now, updatedAt: now),
          ];
          for (final img in itemModifierGroups) {
            await _db.into(_db.itemModifierGroups).insert(itemModifierGroupToCompanion(img));
          }
        }
      });

      AppLogger.info('Onboarding seed completed for company: $companyName (withTestData: $withTestData)');
      return Success(companyId);
    } catch (e, s) {
      AppLogger.error('Onboarding seed failed', error: e, stackTrace: s);
      return Failure('Onboarding seed failed: $e');
    }
  }

}

import 'package:uuid/uuid.dart';

import '../../auth/pin_helper.dart';
import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/company_status.dart';
import '../enums/hardware_type.dart';
import '../enums/item_type.dart';
import '../enums/payment_type.dart';
import '../enums/role_name.dart';
import '../enums/tax_calc_type.dart';
import '../enums/unit_type.dart';
import '../mappers/entity_mappers.dart';
import '../models/category_model.dart';
import '../models/company_model.dart';
import '../models/currency_model.dart';
import '../models/customer_model.dart';
import '../models/item_model.dart';
import '../models/manufacturer_model.dart';
import '../models/payment_method_model.dart';
import '../models/permission_model.dart';
import '../models/register_model.dart';
import '../models/role_model.dart';
import '../models/section_model.dart';
import '../models/supplier_model.dart';
import '../models/table_model.dart';
import '../models/role_permission_model.dart';
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
  }) async {
    try {
      final companyId = _id();
      final currencyId = _id();
      final adminRoleId = _id();
      final operatorRoleId = _id();
      final helperRoleId = _id();
      final userId = _id();
      final registerId = _id();
      final now = DateTime.now();

      await _db.transaction(() async {
        // 1. Currency
        final currency = CurrencyModel(
          id: currencyId,
          code: 'CZK',
          symbol: 'Kč',
          name: 'Česká koruna',
          decimalPlaces: 2,
          createdAt: now,
          updatedAt: now,
        );
        await _db.into(_db.currencies).insert(currencyToCompanion(currency));

        // 2. Company
        final company = CompanyModel(
          id: companyId,
          name: companyName,
          status: CompanyStatus.trial,
          businessId: businessId,
          address: address,
          email: email,
          phone: phone,
          defaultCurrencyId: currencyId,
          authUserId: '',
          createdAt: now,
          updatedAt: now,
        );
        await _db.into(_db.companies).insert(companyToCompanion(company));

        // 3. Tax rates
        final taxRate21Id = _id();
        final taxRate12Id = _id();
        final taxRates = [
          TaxRateModel(
            id: taxRate21Id,
            companyId: companyId,
            label: 'Základní 21%',
            type: TaxCalcType.regular,
            rate: 2100,
            isDefault: true,
            createdAt: now,
            updatedAt: now,
          ),
          TaxRateModel(
            id: taxRate12Id,
            companyId: companyId,
            label: 'Snížená 12%',
            type: TaxCalcType.regular,
            rate: 1200,
            createdAt: now,
            updatedAt: now,
          ),
          TaxRateModel(
            id: _id(),
            companyId: companyId,
            label: 'Nulová 0%',
            type: TaxCalcType.noTax,
            rate: 0,
            createdAt: now,
            updatedAt: now,
          ),
        ];
        for (final tr in taxRates) {
          await _db.into(_db.taxRates).insert(taxRateToCompanion(tr));
        }

        // 4. Permissions (16)
        final permissionDefs = _getPermissionDefinitions();
        final permissionModels = <PermissionModel>[];
        for (final def in permissionDefs) {
          final p = PermissionModel(
            id: _id(),
            code: def['code']!,
            name: def['name']!,
            description: def['description'],
            category: def['category']!,
            createdAt: now,
            updatedAt: now,
          );
          permissionModels.add(p);
          await _db.into(_db.permissions).insert(permissionToCompanion(p));
        }

        // 5. Roles
        final roles = [
          RoleModel(id: helperRoleId, name: RoleName.helper, createdAt: now, updatedAt: now),
          RoleModel(id: operatorRoleId, name: RoleName.operator, createdAt: now, updatedAt: now),
          RoleModel(id: adminRoleId, name: RoleName.admin, createdAt: now, updatedAt: now),
        ];
        for (final r in roles) {
          await _db.into(_db.roles).insert(roleToCompanion(r));
        }

        // 6. Role permissions
        final helperCodes = {
          'bills.create',
          'bills.view',
          'orders.create',
          'orders.view',
          'products.view',
          'customers.view',
        };
        final operatorCodes = {
          ...helperCodes,
          'bills.void',
          'bills.discount',
          'orders.void',
          'orders.discount',
          'tables.manage',
        };
        final adminCodes = {
          ...operatorCodes,
          'products.manage',
          'users.view',
          'users.manage',
          'settings.manage',
          'customers.manage',
        };

        final roleCodeMap = {
          helperRoleId: helperCodes,
          operatorRoleId: operatorCodes,
          adminRoleId: adminCodes,
        };

        for (final entry in roleCodeMap.entries) {
          for (final code in entry.value) {
            final perm = permissionModels.firstWhere((p) => p.code == code);
            final rp = RolePermissionModel(
              id: _id(),
              roleId: entry.key,
              permissionId: perm.id,
              createdAt: now,
              updatedAt: now,
            );
            await _db.into(_db.rolePermissions).insert(rolePermissionToCompanion(rp));
          }
        }

        // 7. Payment methods
        final paymentMethods = [
          PaymentMethodModel(
            id: _id(),
            companyId: companyId,
            name: 'Hotovost',
            type: PaymentType.cash,
            createdAt: now,
            updatedAt: now,
          ),
          PaymentMethodModel(
            id: _id(),
            companyId: companyId,
            name: 'Karta',
            type: PaymentType.card,
            createdAt: now,
            updatedAt: now,
          ),
          PaymentMethodModel(
            id: _id(),
            companyId: companyId,
            name: 'Převod',
            type: PaymentType.bank,
            createdAt: now,
            updatedAt: now,
          ),
        ];
        for (final pm in paymentMethods) {
          await _db.into(_db.paymentMethods).insert(paymentMethodToCompanion(pm));
        }

        // 8. Sections
        final hlavniId = _id();
        final zahradkaId = _id();
        final interniId = _id();
        final sections = [
          SectionModel(id: hlavniId, companyId: companyId, name: 'Hlavní', color: '#4CAF50', isDefault: true, createdAt: now, updatedAt: now),
          SectionModel(id: zahradkaId, companyId: companyId, name: 'Zahrádka', color: '#FF9800', createdAt: now, updatedAt: now),
          SectionModel(id: interniId, companyId: companyId, name: 'Interní', color: '#9E9E9E', createdAt: now, updatedAt: now),
        ];
        for (final s in sections) {
          await _db.into(_db.sections).insert(sectionToCompanion(s));
        }

        // 9. Tables
        final tables = [
          for (var i = 1; i <= 5; i++)
            TableModel(id: _id(), companyId: companyId, name: 'Stůl $i', sectionId: hlavniId, capacity: 4, createdAt: now, updatedAt: now),
          for (var i = 1; i <= 5; i++)
            TableModel(id: _id(), companyId: companyId, name: 'Stolek $i', sectionId: zahradkaId, capacity: 2, createdAt: now, updatedAt: now),
          TableModel(id: _id(), companyId: companyId, name: 'Majitel', sectionId: interniId, capacity: 0, createdAt: now, updatedAt: now),
          TableModel(id: _id(), companyId: companyId, name: 'Repre', sectionId: interniId, capacity: 0, createdAt: now, updatedAt: now),
          TableModel(id: _id(), companyId: companyId, name: 'Odpisy', sectionId: interniId, capacity: 0, createdAt: now, updatedAt: now),
        ];
        for (final t in tables) {
          await _db.into(_db.tables).insert(tableToCompanion(t));
        }

        // 10. Suppliers & Manufacturers (IDs needed by items below)
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

        // 11. Categories
        final catNapoje = _id();
        final catPivo = _id();
        final catHlavniJidla = _id();
        final catPredkrmy = _id();
        final catDeserty = _id();
        final catSuroviny = _id();
        final catSluzby = _id();
        final categories = [
          CategoryModel(id: catNapoje, companyId: companyId, name: 'Nápoje', createdAt: now, updatedAt: now),
          CategoryModel(id: catPivo, companyId: companyId, name: 'Pivo', createdAt: now, updatedAt: now),
          CategoryModel(id: catHlavniJidla, companyId: companyId, name: 'Hlavní jídla', createdAt: now, updatedAt: now),
          CategoryModel(id: catPredkrmy, companyId: companyId, name: 'Předkrmy', createdAt: now, updatedAt: now),
          CategoryModel(id: catDeserty, companyId: companyId, name: 'Dezerty', createdAt: now, updatedAt: now),
          CategoryModel(id: catSuroviny, companyId: companyId, name: 'Suroviny', createdAt: now, updatedAt: now),
          CategoryModel(id: catSluzby, companyId: companyId, name: 'Služby', createdAt: now, updatedAt: now),
        ];
        for (final c in categories) {
          await _db.into(_db.categories).insert(categoryToCompanion(c));
        }

        // 12. Items — all ItemType variants, realistic SKU/prices/relations
        Future<void> ins(ItemModel item) async {
          await _db.into(_db.items).insert(itemToCompanion(item));
        }

        // ── Nápoje (12% — nealkoholické) ──
        // Stocked from supplier, some with manufacturer
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Coca-Cola 0.33l', itemType: ItemType.product, sku: 'NAP-001', altSku: '5449000000996', unitPrice: 4900, purchasePrice: 2200, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Mattoni neperlivá 0.33l', itemType: ItemType.product, sku: 'NAP-002', unitPrice: 3900, purchasePrice: 1200, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Džus pomerančový 0.2l', itemType: ItemType.product, sku: 'NAP-003', unitPrice: 4500, purchasePrice: 1800, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Kofola Original 0.5l', itemType: ItemType.product, sku: 'NAP-004', altSku: '8593868001019', unitPrice: 4500, purchasePrice: 1800, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, manufacturerId: mfrKofolaId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Rajec jemně perlivá 0.33l', itemType: ItemType.product, sku: 'NAP-005', unitPrice: 3900, purchasePrice: 1100, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ks, isStockTracked: true, supplierId: supplierNapojeId, manufacturerId: mfrKofolaId, createdAt: now, updatedAt: now));
        // In-house drinks — no supplier, no purchase price, no stock tracking
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Espresso', itemType: ItemType.product, sku: 'NAP-006', unitPrice: 5500, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Cappuccino', itemType: ItemType.product, sku: 'NAP-007', unitPrice: 6500, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Čaj (výběr)', itemType: ItemType.product, sku: 'NAP-008', unitPrice: 4500, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: 'Domácí limonáda 0.4l', itemType: ItemType.product, sku: 'NAP-009', unitPrice: 6900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));

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
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: 'Svíčková na smetaně', itemType: ItemType.product, sku: 'HJ-001', unitPrice: 22900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: 'Řízek s bramborovým salátem', itemType: ItemType.product, sku: 'HJ-002', unitPrice: 19900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: 'Grilovaný losos', itemType: ItemType.product, sku: 'HJ-003', unitPrice: 27900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: 'Kuřecí steak s hranolky', itemType: ItemType.product, sku: 'HJ-004', unitPrice: 18900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        // Recipe — composite (assembled from ingredients)
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: 'Smažený sýr s hranolky', itemType: ItemType.recipe, sku: 'HJ-005', unitPrice: 17900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        // Parent product with variants
        final burgerParentId = _id();
        await ins(ItemModel(id: burgerParentId, companyId: companyId, categoryId: catHlavniJidla, name: 'Hovězí burger', itemType: ItemType.product, sku: 'HJ-006', unitPrice: 21900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: 'Burger – klasický', itemType: ItemType.variant, sku: 'HJ-006-KLA', unitPrice: 21900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, parentId: burgerParentId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: 'Burger – double', itemType: ItemType.variant, sku: 'HJ-006-DBL', unitPrice: 25900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, parentId: burgerParentId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: 'Burger – vegetariánský', itemType: ItemType.variant, sku: 'HJ-006-VEG', unitPrice: 18900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, parentId: burgerParentId, createdAt: now, updatedAt: now));
        // Modifiers (no category, no SKU — add-ons across menu)
        await ins(ItemModel(id: _id(), companyId: companyId, name: 'Extra sýr', itemType: ItemType.modifier, unitPrice: 2900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, name: 'Extra slanina', itemType: ItemType.modifier, unitPrice: 3900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, name: 'Příloha hranolky', itemType: ItemType.modifier, unitPrice: 4900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));

        // ── Předkrmy (12%) ──
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: 'Tatarský biftek', itemType: ItemType.product, sku: 'PK-001', unitPrice: 18900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: 'Carpaccio z hovězího', itemType: ItemType.product, sku: 'PK-002', unitPrice: 16900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: 'Bruschetta', itemType: ItemType.product, sku: 'PK-003', unitPrice: 12900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: 'Polévka dne', itemType: ItemType.product, sku: 'PK-004', unitPrice: 6900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: 'Caesar salát', itemType: ItemType.product, sku: 'PK-005', unitPrice: 14900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));

        // ── Dezerty (12%) ──
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: 'Tiramisu', itemType: ItemType.product, sku: 'DES-001', unitPrice: 11900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: 'Čokoládový fondant', itemType: ItemType.product, sku: 'DES-002', unitPrice: 13900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: 'Palačinky s Nutellou', itemType: ItemType.product, sku: 'DES-003', unitPrice: 10900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: 'Zmrzlinový pohár', itemType: ItemType.product, sku: 'DES-004', unitPrice: 9900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: 'Jablečný štrúdl', itemType: ItemType.product, sku: 'DES-005', unitPrice: 8900, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now));

        // ── Suroviny / Ingredients (12%, not sellable, stock tracked, from Makro) ──
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: 'Kuřecí prsa', itemType: ItemType.ingredient, sku: 'SUR-001', unitPrice: 18900, purchasePrice: 18900, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.g, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: 'Hovězí svíčková', itemType: ItemType.ingredient, sku: 'SUR-002', unitPrice: 34900, purchasePrice: 34900, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.g, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: 'Mouka hladká', itemType: ItemType.ingredient, sku: 'SUR-003', unitPrice: 2900, purchasePrice: 2900, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.g, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: 'Smetana 33%', itemType: ItemType.ingredient, sku: 'SUR-004', unitPrice: 6900, purchasePrice: 6900, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.ml, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: 'Eidam 30%', itemType: ItemType.ingredient, sku: 'SUR-005', unitPrice: 15900, purchasePrice: 15900, saleTaxRateId: taxRate12Id, purchaseTaxRateId: taxRate12Id, unit: UnitType.g, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));

        // ── Counter / Spotřební materiál (21%, not sellable, stock tracked, from Makro) ──
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: 'Ubrousek', itemType: ItemType.counter, sku: 'SPT-001', unitPrice: 100, purchasePrice: 50, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: 'Kelímek na odnos', itemType: ItemType.counter, sku: 'SPT-002', unitPrice: 500, purchasePrice: 250, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSuroviny, name: 'Papírový tácek', itemType: ItemType.counter, sku: 'SPT-003', unitPrice: 200, purchasePrice: 100, saleTaxRateId: taxRate21Id, purchaseTaxRateId: taxRate21Id, unit: UnitType.ks, isSellable: false, isStockTracked: true, supplierId: supplierMakroId, createdAt: now, updatedAt: now));

        // ── Služby / Services (21%, no stock) ──
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSluzby, name: 'Pronájem sálu (hodina)', itemType: ItemType.service, sku: 'SLU-001', unitPrice: 150000, saleTaxRateId: taxRate21Id, unit: UnitType.ks, createdAt: now, updatedAt: now));
        await ins(ItemModel(id: _id(), companyId: companyId, categoryId: catSluzby, name: 'Raut – obsluha (osoba)', itemType: ItemType.service, sku: 'SLU-002', unitPrice: 50000, saleTaxRateId: taxRate21Id, unit: UnitType.ks, createdAt: now, updatedAt: now));

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

        // 14. Register
        final register = RegisterModel(
          id: registerId,
          companyId: companyId,
          code: 'REG-1',
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
              type: register.type,
            ));

        // 9. Admin user
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

        // 10. User permissions (admin gets all 16)
        for (final perm in permissionModels) {
          final up = UserPermissionModel(
            id: _id(),
            companyId: companyId,
            userId: userId,
            permissionId: perm.id,
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

  List<Map<String, String>> _getPermissionDefinitions() {
    return [
      {'code': 'bills.create', 'name': 'Create bill', 'category': 'bills'},
      {'code': 'bills.view', 'name': 'View bills', 'category': 'bills'},
      {'code': 'bills.void', 'name': 'Void bill', 'category': 'bills'},
      {'code': 'bills.discount', 'name': 'Apply bill discount', 'category': 'bills'},
      {'code': 'orders.create', 'name': 'Create order', 'category': 'orders'},
      {'code': 'orders.view', 'name': 'View orders', 'category': 'orders'},
      {'code': 'orders.void', 'name': 'Void order', 'category': 'orders'},
      {'code': 'orders.discount', 'name': 'Apply item discount', 'category': 'orders'},
      {'code': 'products.view', 'name': 'View products', 'category': 'products'},
      {'code': 'products.manage', 'name': 'Manage products', 'category': 'products'},
      {'code': 'tables.manage', 'name': 'Manage tables', 'category': 'tables'},
      {'code': 'users.view', 'name': 'View users', 'category': 'users'},
      {'code': 'users.manage', 'name': 'Manage users', 'category': 'users'},
      {'code': 'settings.manage', 'name': 'Manage settings', 'category': 'settings'},
      {'code': 'customers.view', 'name': 'View customers', 'category': 'customers'},
      {'code': 'customers.manage', 'name': 'Manage customers', 'category': 'customers'},
    ];
  }
}

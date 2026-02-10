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
import '../models/item_model.dart';
import '../models/payment_method_model.dart';
import '../models/permission_model.dart';
import '../models/register_model.dart';
import '../models/role_model.dart';
import '../models/section_model.dart';
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

        // 4. Permissions (14)
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

        // 10. Categories & Items
        final catNapoje = _id();
        final catPivo = _id();
        final catHlavniJidla = _id();
        final catPredkrmy = _id();
        final catDeserty = _id();
        final categories = [
          CategoryModel(id: catNapoje, companyId: companyId, name: 'Nápoje', createdAt: now, updatedAt: now),
          CategoryModel(id: catPivo, companyId: companyId, name: 'Pivo', createdAt: now, updatedAt: now),
          CategoryModel(id: catHlavniJidla, companyId: companyId, name: 'Hlavní jídla', createdAt: now, updatedAt: now),
          CategoryModel(id: catPredkrmy, companyId: companyId, name: 'Předkrmy', createdAt: now, updatedAt: now),
          CategoryModel(id: catDeserty, companyId: companyId, name: 'Dezerty', createdAt: now, updatedAt: now),
        ];
        for (final c in categories) {
          await _db.into(_db.categories).insert(categoryToCompanion(c));
        }

        // Nápoje (12% tax - food/beverage)
        final napojeItems = [
          ('Coca-Cola 0.33l', 4900),
          ('Minerální voda 0.33l', 3900),
          ('Džus pomerančový 0.2l', 4500),
          ('Espresso', 5500),
          ('Čaj', 4500),
        ];
        for (final (name, price) in napojeItems) {
          final item = ItemModel(id: _id(), companyId: companyId, categoryId: catNapoje, name: name, itemType: ItemType.product, unitPrice: price, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now);
          await _db.into(_db.items).insert(itemToCompanion(item));
        }

        // Pivo (21% tax - alcohol)
        final pivoItems = [
          ('Pilsner Urquell 0.5l', 5900),
          ('Kozel 11° 0.5l', 4900),
          ('Staropramen 0.5l', 4500),
          ('Bernard 12° 0.5l', 5500),
          ('Nealkoholické pivo 0.5l', 4500),
        ];
        for (final (name, price) in pivoItems) {
          final item = ItemModel(id: _id(), companyId: companyId, categoryId: catPivo, name: name, itemType: ItemType.product, unitPrice: price, saleTaxRateId: taxRate21Id, unit: UnitType.ks, createdAt: now, updatedAt: now);
          await _db.into(_db.items).insert(itemToCompanion(item));
        }

        // Hlavní jídla (12% tax)
        final hlavniItems = [
          ('Svíčková na smetaně', 22900),
          ('Řízek s bramborovým salátem', 19900),
          ('Grilovaný losos', 27900),
          ('Hovězí burger', 21900),
          ('Kuřecí steak s hranolky', 18900),
        ];
        for (final (name, price) in hlavniItems) {
          final item = ItemModel(id: _id(), companyId: companyId, categoryId: catHlavniJidla, name: name, itemType: ItemType.product, unitPrice: price, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now);
          await _db.into(_db.items).insert(itemToCompanion(item));
        }

        // Předkrmy (12% tax)
        final predkrmyItems = [
          ('Tatarský biftek', 18900),
          ('Carpaccio z hovězího', 16900),
          ('Bruschetta', 12900),
          ('Polévka dne', 6900),
          ('Caesar salát', 14900),
        ];
        for (final (name, price) in predkrmyItems) {
          final item = ItemModel(id: _id(), companyId: companyId, categoryId: catPredkrmy, name: name, itemType: ItemType.product, unitPrice: price, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now);
          await _db.into(_db.items).insert(itemToCompanion(item));
        }

        // Dezerty (12% tax)
        final desertyItems = [
          ('Tiramisu', 11900),
          ('Čokoládový fondant', 13900),
          ('Palačinky s Nutellou', 10900),
          ('Zmrzlinový pohár', 9900),
          ('Jablečný štrúdl', 8900),
        ];
        for (final (name, price) in desertyItems) {
          final item = ItemModel(id: _id(), companyId: companyId, categoryId: catDeserty, name: name, itemType: ItemType.product, unitPrice: price, saleTaxRateId: taxRate12Id, unit: UnitType.ks, createdAt: now, updatedAt: now);
          await _db.into(_db.items).insert(itemToCompanion(item));
        }

        // 11. Register
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

        // 10. User permissions (admin gets all 14)
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
    ];
  }
}

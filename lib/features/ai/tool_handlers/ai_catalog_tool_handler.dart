import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/data/enums/enums.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/manufacturer_model.dart';
import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/models/tax_rate_model.dart';
import '../../../core/data/repositories/category_repository.dart';
import '../../../core/data/utils/category_tree.dart';
import '../../../core/data/repositories/item_repository.dart';
import '../../../core/data/repositories/manufacturer_repository.dart';
import '../../../core/data/repositories/supplier_repository.dart';
import '../../../core/data/repositories/tax_rate_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/logging/app_logger.dart';
import '../models/ai_command_result.dart';

const _uuid = Uuid();

/// Handles catalog-domain AI tool calls: items, categories, tax rates,
/// manufacturers, suppliers.
class AiCatalogToolHandler {
  AiCatalogToolHandler({
    required ItemRepository itemRepo,
    required CategoryRepository categoryRepo,
    required TaxRateRepository taxRateRepo,
    required ManufacturerRepository manufacturerRepo,
    required SupplierRepository supplierRepo,
  })  : _itemRepo = itemRepo,
        _categoryRepo = categoryRepo,
        _taxRateRepo = taxRateRepo,
        _manufacturerRepo = manufacturerRepo,
        _supplierRepo = supplierRepo;

  final ItemRepository _itemRepo;
  final CategoryRepository _categoryRepo;
  final TaxRateRepository _taxRateRepo;
  final ManufacturerRepository _manufacturerRepo;
  final SupplierRepository _supplierRepo;

  Future<AiCommandResult> handle(
    String toolName,
    Map<String, dynamic> args,
    String companyId,
  ) async {
    try {
      return switch (toolName) {
        // Items
        'list_items' => _listItems(args, companyId),
        'search_items' => _searchItems(args, companyId),
        'get_item' => _getItem(args),
        'create_item' => _createItem(args, companyId),
        'update_item' => _updateItem(args),
        'delete_item' => _deleteItem(args),
        // Categories
        'list_categories' => _listCategories(companyId),
        'get_category' => _getCategory(args),
        'create_category' => _createCategory(args, companyId),
        'update_category' => _updateCategory(args),
        'delete_category' => _deleteCategory(args),
        // Tax rates
        'list_tax_rates' => _listTaxRates(companyId),
        'create_tax_rate' => _createTaxRate(args, companyId),
        'update_tax_rate' => _updateTaxRate(args),
        'delete_tax_rate' => _deleteTaxRate(args),
        // Manufacturers
        'list_manufacturers' => _listManufacturers(companyId),
        'create_manufacturer' => _createManufacturer(args, companyId),
        'update_manufacturer' => _updateManufacturer(args),
        'delete_manufacturer' => _deleteManufacturer(args),
        // Suppliers
        'list_suppliers' => _listSuppliers(companyId),
        'create_supplier' => _createSupplier(args, companyId),
        'update_supplier' => _updateSupplier(args),
        'delete_supplier' => _deleteSupplier(args),
        _ => AiCommandError('Unknown catalog tool: $toolName'),
      };
    } catch (e, s) {
      AppLogger.error('Catalog tool handler error', tag: 'AI', error: e, stackTrace: s);
      return AiCommandError('Tool execution failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Items
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listItems(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final categoryId = args['category_id'] as String?;
    final all = await _itemRepo.watchAll(companyId).first;
    List<ItemModel> filtered;
    if (categoryId != null) {
      final allCats = await _categoryRepo.watchAll(companyId).first;
      final ids = CategoryTree.getAllDescendantIds(categoryId, allCats);
      filtered = all.where((i) => i.categoryId != null && ids.contains(i.categoryId)).toList();
    } else {
      filtered = all;
    }
    final json = filtered.take(1000)
        .map((i) => {
              'id': i.id,
              'name': i.name,
              'unit_price': i.unitPrice,
              'purchase_price': i.purchasePrice,
              'category_id': i.categoryId,
              'sku': i.sku,
              'item_type': i.itemType.name,
              'is_active': i.isActive,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _searchItems(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final query = args['query'] as String;
    final items = await _itemRepo.search(companyId, query).first;
    final json = items.take(1000)
        .map((i) => {
              'id': i.id,
              'name': i.name,
              'unit_price': i.unitPrice,
              'purchase_price': i.purchasePrice,
              'category_id': i.categoryId,
              'sku': i.sku,
              'item_type': i.itemType.name,
              'is_active': i.isActive,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _getItem(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final item = await _itemRepo.getById(id);
    if (item == null) return const AiCommandError('Item not found');
    return AiCommandSuccess(jsonEncode({
      'id': item.id,
      'name': item.name,
      'unit_price': item.unitPrice,
      'purchase_price': item.purchasePrice,
      'category_id': item.categoryId,
      'sku': item.sku,
      'item_type': item.itemType.name,
      'unit': item.unit.name,
      'is_active': item.isActive,
      'is_sellable': item.isSellable,
      'sale_tax_rate_id': item.saleTaxRateId,
      'manufacturer_id': item.manufacturerId,
      'supplier_id': item.supplierId,
    }));
  }

  Future<AiCommandResult> _createItem(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = ItemModel(
      id: _uuid.v7(),
      companyId: companyId,
      name: args['name'] as String,
      categoryId: args['category_id'] as String?,
      unitPrice: (args['unit_price'] as num?)?.toInt(),
      itemType: args['item_type'] != null
          ? ItemType.values.byName(args['item_type'] as String)
          : ItemType.product,
      unit: args['unit'] != null
          ? UnitType.values.byName(args['unit'] as String)
          : UnitType.ks,
      sku: args['sku'] as String?,
      saleTaxRateId: args['sale_tax_rate_id'] as String?,
      isActive: args['is_active'] as bool? ?? true,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _itemRepo.create(model);
    return switch (result) {
      Success(:final value) =>
        AiCommandSuccess('Item "${value.name}" created', entityId: value.id),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateItem(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final existing = await _itemRepo.getById(id);
    if (existing == null) return const AiCommandError('Item not found');

    final updated = existing.copyWith(
      name: args['name'] as String? ?? existing.name,
      categoryId: args.containsKey('category_id')
          ? args['category_id'] as String?
          : existing.categoryId,
      unitPrice: args.containsKey('unit_price')
          ? (args['unit_price'] as num?)?.toInt()
          : existing.unitPrice,
      itemType: args['item_type'] != null
          ? ItemType.values.byName(args['item_type'] as String)
          : existing.itemType,
      unit: args['unit'] != null
          ? UnitType.values.byName(args['unit'] as String)
          : existing.unit,
      sku: args.containsKey('sku') ? args['sku'] as String? : existing.sku,
      saleTaxRateId: args.containsKey('sale_tax_rate_id')
          ? args['sale_tax_rate_id'] as String?
          : existing.saleTaxRateId,
      isActive: args['is_active'] as bool? ?? existing.isActive,
      updatedAt: DateTime.now(),
    );
    final result = await _itemRepo.update(updated);
    return switch (result) {
      Success(:final value) =>
        AiCommandSuccess('Item "${value.name}" updated', entityId: value.id),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteItem(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final result = await _itemRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Item deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listCategories(String companyId) async {
    final categories = await _categoryRepo.watchAll(companyId).first;
    final json = categories.take(1000)
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'is_active': c.isActive,
              'parent_id': c.parentId,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _getCategory(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final category = await _categoryRepo.getById(id);
    if (category == null) return const AiCommandError('Category not found');
    return AiCommandSuccess(jsonEncode({
      'id': category.id,
      'name': category.name,
      'is_active': category.isActive,
      'parent_id': category.parentId,
    }));
  }

  Future<AiCommandResult> _createCategory(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = CategoryModel(
      id: _uuid.v7(),
      companyId: companyId,
      name: args['name'] as String,
      parentId: args['parent_id'] as String?,
      isActive: args['is_active'] as bool? ?? true,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _categoryRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Category "${value.name}" created',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateCategory(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final existing = await _categoryRepo.getById(id);
    if (existing == null) return const AiCommandError('Category not found');

    final updated = existing.copyWith(
      name: args['name'] as String? ?? existing.name,
      parentId: args.containsKey('parent_id')
          ? args['parent_id'] as String?
          : existing.parentId,
      isActive: args['is_active'] as bool? ?? existing.isActive,
      updatedAt: DateTime.now(),
    );
    final result = await _categoryRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Category "${value.name}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteCategory(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final result = await _categoryRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Category deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }

  // ---------------------------------------------------------------------------
  // Tax Rates
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listTaxRates(String companyId) async {
    final rates = await _taxRateRepo.watchAll(companyId).first;
    final json = rates.take(1000)
        .map((t) => {
              'id': t.id,
              'label': t.label,
              'type': t.type.name,
              'rate': t.rate,
              'is_default': t.isDefault,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _createTaxRate(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = TaxRateModel(
      id: _uuid.v7(),
      companyId: companyId,
      label: args['label'] as String,
      type: args['type'] != null
          ? TaxCalcType.values.byName(args['type'] as String)
          : TaxCalcType.regular,
      rate: (args['rate'] as num).toInt(),
      isDefault: args['is_default'] as bool? ?? false,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _taxRateRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Tax rate "${value.label}" created',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateTaxRate(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final existing = await _taxRateRepo.getById(id);
    if (existing == null) return const AiCommandError('Tax rate not found');

    final updated = existing.copyWith(
      label: args['label'] as String? ?? existing.label,
      rate: (args['rate'] as num?)?.toInt() ?? existing.rate,
      isDefault: args['is_default'] as bool? ?? existing.isDefault,
      updatedAt: DateTime.now(),
    );
    final result = await _taxRateRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Tax rate "${value.label}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteTaxRate(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final result = await _taxRateRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Tax rate deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }

  // ---------------------------------------------------------------------------
  // Manufacturers
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listManufacturers(String companyId) async {
    final manufacturers = await _manufacturerRepo.watchAll(companyId).first;
    final json = manufacturers.take(1000)
        .map((m) => {'id': m.id, 'name': m.name})
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _createManufacturer(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = ManufacturerModel(
      id: _uuid.v7(),
      companyId: companyId,
      name: args['name'] as String,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _manufacturerRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Manufacturer "${value.name}" created',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateManufacturer(
    Map<String, dynamic> args,
  ) async {
    final id = args['id'] as String;
    final existing = await _manufacturerRepo.getById(id);
    if (existing == null) {
      return const AiCommandError('Manufacturer not found');
    }

    final updated = existing.copyWith(
      name: args['name'] as String? ?? existing.name,
      updatedAt: DateTime.now(),
    );
    final result = await _manufacturerRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Manufacturer "${value.name}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteManufacturer(
    Map<String, dynamic> args,
  ) async {
    final id = args['id'] as String;
    final result = await _manufacturerRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Manufacturer deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }

  // ---------------------------------------------------------------------------
  // Suppliers
  // ---------------------------------------------------------------------------

  Future<AiCommandResult> _listSuppliers(String companyId) async {
    final suppliers = await _supplierRepo.watchAll(companyId).first;
    final json = suppliers.take(1000)
        .map((s) => {
              'id': s.id,
              'supplier_name': s.supplierName,
              'contact_person': s.contactPerson,
              'email': s.email,
              'phone': s.phone,
            })
        .toList();
    return AiCommandSuccess(jsonEncode(json));
  }

  Future<AiCommandResult> _createSupplier(
    Map<String, dynamic> args,
    String companyId,
  ) async {
    final now = DateTime.now();
    final model = SupplierModel(
      id: _uuid.v7(),
      companyId: companyId,
      supplierName: args['supplier_name'] as String,
      contactPerson: args['contact_person'] as String?,
      email: args['email'] as String?,
      phone: args['phone'] as String?,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _supplierRepo.create(model);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Supplier "${value.supplierName}" created',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _updateSupplier(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final existing = await _supplierRepo.getById(id);
    if (existing == null) return const AiCommandError('Supplier not found');

    final updated = existing.copyWith(
      supplierName:
          args['supplier_name'] as String? ?? existing.supplierName,
      contactPerson: args.containsKey('contact_person')
          ? args['contact_person'] as String?
          : existing.contactPerson,
      email:
          args.containsKey('email') ? args['email'] as String? : existing.email,
      phone:
          args.containsKey('phone') ? args['phone'] as String? : existing.phone,
      updatedAt: DateTime.now(),
    );
    final result = await _supplierRepo.update(updated);
    return switch (result) {
      Success(:final value) => AiCommandSuccess(
          'Supplier "${value.supplierName}" updated',
          entityId: value.id,
        ),
      Failure(:final message) => AiCommandError(message),
    };
  }

  Future<AiCommandResult> _deleteSupplier(Map<String, dynamic> args) async {
    final id = args['id'] as String;
    final result = await _supplierRepo.delete(id);
    return switch (result) {
      Success() => AiCommandSuccess('Supplier deleted', entityId: id),
      Failure(:final message) => AiCommandError(message),
    };
  }
}

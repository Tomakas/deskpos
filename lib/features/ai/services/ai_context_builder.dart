import '../../../core/data/repositories/category_repository.dart';
import '../../../core/data/repositories/item_repository.dart';
import '../../../core/data/repositories/payment_method_repository.dart';
import '../../../core/data/repositories/section_repository.dart';
import '../../../core/data/repositories/table_repository.dart';
import '../../../core/data/repositories/tax_rate_repository.dart';
import '../../../core/data/repositories/user_repository.dart';
import '../models/catalog_summary.dart';

/// Builds [CatalogSummary] from repositories with 5-minute cache.
class AiContextBuilder {
  AiContextBuilder({
    required CategoryRepository categoryRepo,
    required ItemRepository itemRepo,
    required TaxRateRepository taxRateRepo,
    required PaymentMethodRepository paymentMethodRepo,
    required UserRepository userRepo,
    required SectionRepository sectionRepo,
    required TableRepository tableRepo,
  })  : _categoryRepo = categoryRepo,
        _itemRepo = itemRepo,
        _taxRateRepo = taxRateRepo,
        _paymentMethodRepo = paymentMethodRepo,
        _userRepo = userRepo,
        _sectionRepo = sectionRepo,
        _tableRepo = tableRepo;

  final CategoryRepository _categoryRepo;
  final ItemRepository _itemRepo;
  final TaxRateRepository _taxRateRepo;
  final PaymentMethodRepository _paymentMethodRepo;
  final UserRepository _userRepo;
  final SectionRepository _sectionRepo;
  final TableRepository _tableRepo;

  static const _cacheDuration = Duration(minutes: 5);

  CatalogSummary? _cachedSummary;
  DateTime? _cachedAt;

  /// Builds a sanitized catalog summary for the system prompt.
  ///
  /// Returns cached result if less than 5 minutes old.
  Future<CatalogSummary> buildCatalogSummary(String companyId) async {
    final now = DateTime.now();
    if (_cachedSummary != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheDuration) {
      return _cachedSummary!;
    }

    // Fetch all data in parallel
    final results = await Future.wait([
      _categoryRepo.watchAll(companyId).first, // 0
      _itemRepo.watchAll(companyId).first, // 1
      _taxRateRepo.watchAll(companyId).first, // 2
      _paymentMethodRepo.watchAll(companyId).first, // 3
      _userRepo.watchAll(companyId).first, // 4
      _sectionRepo.watchAll(companyId).first, // 5
      _tableRepo.watchAll(companyId).first, // 6
    ]);

    final categories = results[0] as List;
    final items = results[1] as List;
    final taxRates = results[2] as List;
    final paymentMethods = results[3] as List;
    final users = results[4] as List;
    final sections = results[5] as List;
    final tables = results[6] as List;

    // Count items by category
    final itemCounts = <String, int>{};
    for (final item in items) {
      final catId = (item as dynamic).categoryId as String?;
      if (catId != null) {
        itemCounts[catId] = (itemCounts[catId] ?? 0) + 1;
      }
    }

    _cachedSummary = CatalogSummary(
      categories: categories
          .map(
            (c) => (
              id: (c as dynamic).id as String,
              name: (c as dynamic).name as String,
              isActive: (c as dynamic).isActive as bool,
              parentId: (c as dynamic).parentId as String?,
            ),
          )
          .toList(),
      itemCountsByCategory: itemCounts,
      taxRates: taxRates
          .map(
            (t) => (
              id: (t as dynamic).id as String,
              label: (t as dynamic).label as String,
              type: ((t as dynamic).type as Enum).name,
              rate: (t as dynamic).rate as int,
              isDefault: (t as dynamic).isDefault as bool,
            ),
          )
          .toList(),
      paymentMethods: paymentMethods
          .map(
            (p) => (
              id: (p as dynamic).id as String,
              name: (p as dynamic).name as String,
              type: ((p as dynamic).type as Enum).name,
              isActive: (p as dynamic).isActive as bool,
            ),
          )
          .toList(),
      // Strip sensitive fields: no pinHash, no authUserId
      users: users
          .map(
            (u) => (
              id: (u as dynamic).id as String,
              fullName: (u as dynamic).fullName as String,
              email: (u as dynamic).email as String?,
            ),
          )
          .toList(),
      sections: sections
          .map(
            (s) => (
              id: (s as dynamic).id as String,
              name: (s as dynamic).name as String,
              isActive: (s as dynamic).isActive as bool,
            ),
          )
          .toList(),
      tables: tables
          .map(
            (t) => (
              id: (t as dynamic).id as String,
              name: (t as dynamic).name as String,
              sectionId: (t as dynamic).sectionId as String?,
              capacity: (t as dynamic).capacity as int,
            ),
          )
          .toList(),
    );

    _cachedAt = now;
    return _cachedSummary!;
  }

  /// Invalidates the cached summary.
  void invalidateCache() {
    _cachedSummary = null;
    _cachedAt = null;
  }
}

import '../models/category_model.dart';

class CategoryDisplayItem {
  final CategoryModel category;
  final int depth;

  CategoryDisplayItem({required this.category, required this.depth});
}

class CategoryTree {
  CategoryTree._();

  /// Returns the ID of [categoryId] plus all its descendants (any depth).
  ///
  /// Uses BFS with a visited set to handle potential cycles in data.
  static Set<String> getAllDescendantIds(
    String categoryId,
    List<CategoryModel> allCategories,
  ) {
    final result = <String>{categoryId};
    final queue = <String>[categoryId];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      for (final cat in allCategories) {
        if (cat.parentId == current && !result.contains(cat.id)) {
          result.add(cat.id);
          queue.add(cat.id);
        }
      }
    }
    return result;
  }

  /// Walks up the category tree from [categoryId] and returns the first
  /// non-null [CategoryModel.itemColor] found. Returns null if none is set.
  static String? resolveAncestorColor(
    String? categoryId,
    Map<String, CategoryModel> categoriesMap,
  ) {
    var id = categoryId;
    while (id != null) {
      final cat = categoriesMap[id];
      if (cat == null) break;
      if (cat.itemColor != null) return cat.itemColor;
      id = cat.parentId;
    }
    return null;
  }

  /// Returns a flat list of categories sorted by hierarchy (parent followed by children).
  /// Useful for dropdown menus to show tree structure.
  static List<CategoryDisplayItem> getSortedDisplayList(
    List<CategoryModel> allCategories, {
    String? parentId,
    int depth = 0,
  }) {
    final result = <CategoryDisplayItem>[];
    
    // Find direct children of current parent
    final children = allCategories
        .where((c) => c.parentId == parentId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    for (final child in children) {
      result.add(CategoryDisplayItem(category: child, depth: depth));
      // Recursively add grandchildren
      result.addAll(getSortedDisplayList(
        allCategories,
        parentId: child.id,
        depth: depth + 1,
      ));
    }
    
    return result;
  }
}

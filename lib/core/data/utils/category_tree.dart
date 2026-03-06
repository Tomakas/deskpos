import '../models/category_model.dart';

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
}

// lib/home/mixins/category_helpers.dart
import 'package:zad/models/categories.dart';

mixin CategoryHelpers {
  Set<int> getCategoryIdsIncludingChildren(Category category) {
    final ids = <int>{category.catid};
    if (category.children != null) {
      for (final child in category.children!) {
        ids.addAll(getCategoryIdsIncludingChildren(child));
      }
    }
    return ids;
  }

  Category? findCategoryById(List<Category> tree, int id) {
    for (final c in tree) {
      if (c.catid == id) return c;
      if (c.children != null) {
        final found = findCategoryById(c.children!, id);
        if (found != null) return found;
      }
    }
    return null;
  }
}

class FavoritesModel {
  static final List<Map<String, dynamic>> items = [];

  static void add(Map<String, dynamic> item) {
    if (!items.any((e) => e['name'] == item['name'])) {
      items.add(item);
    }
  }

  static void remove(String name) {
    items.removeWhere((e) => e['name'] == name);
  }

  static bool isFavorited(String name) {
    return items.any((e) => e['name'] == name);
  }
}
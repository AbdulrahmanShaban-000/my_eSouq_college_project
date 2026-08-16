class Category {
  final int catid;
  final String name;
  final String? slug;
  final String? description;
  final int? parentId;
  final List<Category>? children;

  Category({
    required this.catid,
    required this.name,
    this.slug,
    this.description,
    this.parentId,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      catid: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      parentId: json['parent_id'],
      children: json['children'] != null
          ? List<Category>.from(
              json['children'].map((x) => Category.fromJson(x)),
            )
          : null,
    );
  }
}

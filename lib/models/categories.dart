// // To parse this JSON data, do
// //
// //     final item = itemFromJson(jsonString);

// import 'dart:convert';

// Categories itemFromJson(String str) => Categories.fromJson(json.decode(str));

// String itemToJson(Categories data) => json.encode(data.toJson());

// class Categories {
//   String name;
//   String slug;
//   String description;
//   String parentId;

//   Categories({
//     required this.name,
//     required this.slug,
//     required this.description,
//     required this.parentId,
//   });

//   factory Categories.fromJson(Map<String, dynamic> json) => Categories(
//     name: json["name"],
//     slug: json["slug"],
//     description: json["description"],
//     parentId: json["parent_id"],
//   );

//   Map<String, dynamic> toJson() => {
//     "name": name,
//     "slug": slug,
//     "description": description,
//     "parent_id": parentId,
//   };
// }

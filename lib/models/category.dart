class Category {
  final int? id;
  final String name;
  final int? parentId; 

  Category({this.id, required this.name, this.parentId});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'parent_id': parentId,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'],
        name: map['name'],
        parentId: map['parent_id'],
      );
}

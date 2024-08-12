class Area {
  final String id;
  final String name;

  Area({required this.id, required this.name});

  factory Area.fromMap(Map<String, dynamic> map, String id) {
    return Area(
      id: id,
      name: map['area_name'] ?? '',
    );
  }
}

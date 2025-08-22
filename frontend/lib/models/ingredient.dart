class Ingredient {
  final int id;
  final String ingredientName;
  final String? description;
  final String storageLocation;
  final DateTime? storageDate;
  final DateTime? expirationDate;
  final int? daysLeft;

  Ingredient({
    required this.id,
    required this.ingredientName,
    this.description,
    required this.storageLocation,
    this.storageDate,
    this.expirationDate,
    this.daysLeft,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    DateTime? _parse(String? s) => s == null ? null : DateTime.tryParse(s);
    return Ingredient(
      id: (json['id'] as num).toInt(),
      ingredientName: json['ingredientName'] as String,
      description: json['description'] as String?,
      storageLocation: json['storageLocation'] as String,
      storageDate: _parse(json['storageDate'] as String?),
      expirationDate: _parse(json['expirationDate'] as String?),
      daysLeft: json['daysLeft'] == null ? null : (json['daysLeft'] as num).toInt(),
    );
  }
}
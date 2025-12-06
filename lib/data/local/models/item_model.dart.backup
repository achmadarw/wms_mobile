import 'package:json_annotation/json_annotation.dart';

part 'item_model.g.dart';

@JsonSerializable()
class ItemModel {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String category;
  final String? unitOfMeasure;
  final double? weight;
  final String? dimensions;
  final double unitCost;
  final double? sellingPrice;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemModel({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    required this.category,
    this.unitOfMeasure,
    this.weight,
    this.dimensions,
    required this.unitCost,
    this.sellingPrice,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);

  ItemModel copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    String? category,
    String? unitOfMeasure,
    double? weight,
    String? dimensions,
    double? unitCost,
    double? sellingPrice,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      unitCost: unitCost ?? this.unitCost,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

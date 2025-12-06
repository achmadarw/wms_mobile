// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemModel _$ItemModelFromJson(Map<String, dynamic> json) => ItemModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      unitOfMeasure: json['unitOfMeasure'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      dimensions: json['dimensions'] as String?,
      unitCost: (json['unitCost'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ItemModelToJson(ItemModel instance) => <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'unitOfMeasure': instance.unitOfMeasure,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'unitCost': instance.unitCost,
      'sellingPrice': instance.sellingPrice,
      'active': instance.active,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

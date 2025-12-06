class MovementModel {
  final String id;
  final String referenceNo;
  final String type;
  final int quantity;
  final String? notes;
  final String status;
  final String? fromBin;
  final String? toBin;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final String itemId;
  final ItemInfo? item;
  final String warehouseId;
  final WarehouseInfo? warehouse;
  final String createdById;
  final UserInfo? createdBy;

  MovementModel({
    required this.id,
    required this.referenceNo,
    required this.type,
    required this.quantity,
    this.notes,
    required this.status,
    this.fromBin,
    this.toBin,
    required this.createdAt,
    required this.updatedAt,
    required this.itemId,
    this.item,
    required this.warehouseId,
    this.warehouse,
    required this.createdById,
    this.createdBy,
  });

  factory MovementModel.fromJson(Map<String, dynamic> json) {
    return MovementModel(
      id: json['id'] as String,
      referenceNo: json['referenceNo'] as String,
      type: json['type'] as String,
      quantity: json['quantity'] as int,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      fromBin: json['fromBin'] as String?,
      toBin: json['toBin'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      itemId: json['itemId'] as String,
      item: json['item'] != null
          ? ItemInfo.fromJson(json['item'] as Map<String, dynamic>)
          : null,
      warehouseId: json['warehouseId'] as String,
      warehouse: json['warehouse'] != null
          ? WarehouseInfo.fromJson(json['warehouse'] as Map<String, dynamic>)
          : null,
      createdById: json['createdById'] as String,
      createdBy: json['createdBy'] != null
          ? UserInfo.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referenceNo': referenceNo,
      'type': type,
      'quantity': quantity,
      'notes': notes,
      'status': status,
      'fromBin': fromBin,
      'toBin': toBin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'itemId': itemId,
      'item': item?.toJson(),
      'warehouseId': warehouseId,
      'warehouse': warehouse?.toJson(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
    };
  }

  String get typeLabel {
    switch (type) {
      case 'INBOUND':
        return 'Stock In';
      case 'OUTBOUND':
        return 'Stock Out';
      case 'TRANSFER':
        return 'Transfer';
      case 'ADJUSTMENT':
        return 'Adjustment';
      case 'RETURN':
        return 'Return';
      case 'DAMAGE':
        return 'Damage';
      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class ItemInfo {
  final String id;
  final String sku;
  final String name;
  final String category;
  final String? unitOfMeasure;

  ItemInfo({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    this.unitOfMeasure,
  });

  factory ItemInfo.fromJson(Map<String, dynamic> json) {
    return ItemInfo(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      unitOfMeasure: json['unitOfMeasure'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'unitOfMeasure': unitOfMeasure,
    };
  }
}

class WarehouseInfo {
  final String id;
  final String code;
  final String name;

  WarehouseInfo({
    required this.id,
    required this.code,
    required this.name,
  });

  factory WarehouseInfo.fromJson(Map<String, dynamic> json) {
    return WarehouseInfo(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

class UserInfo {
  final String id;
  final String fullName;
  final String email;

  UserInfo({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
    };
  }
}

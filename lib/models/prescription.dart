class Prescription {
  final int? id;
  final int orderId;
  final int userId;
  final String image;
  final String status; // pending, processing, accepted, declined, completed
  final int? currentVendorId;
  final int attempts;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Optional related data
  final String? orderNumber;
  final Map<String, dynamic>? userData;

  Prescription({
    this.id,
    required this.orderId,
    required this.userId,
    required this.image,
    this.status = 'pending',
    this.currentVendorId,
    this.attempts = 0,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.orderNumber,
    this.userData,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as int?,
      orderId: json['order_id'] as int,
      userId: json['user_id'] as int,
      image: json['image'] as String,
      status: json['status'] as String? ?? 'pending',
      currentVendorId: json['current_vendor_id'] as int?,
      attempts: json['attempts'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      orderNumber: json['order_number'] as String?,
      userData: json['user'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'image': image,
      'status': status,
      'current_vendor_id': currentVendorId,
      'attempts': attempts,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isCompleted => status == 'completed';
}

class Category {
  final int id;
  final String name;
  final String slug;
  final String type; // gas, grocery, medical
  final String? image;
  final String? description;
  final String status;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    this.image,
    this.description,
    this.status = 'active',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      type: json['type'] as String,
      image: json['image'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'type': type,
      'image': image,
      'description': description,
      'status': status,
    };
  }
}

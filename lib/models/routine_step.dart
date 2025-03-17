enum StepType {
  cleanser,
  toner,
  moisturizer,
  sunscreen,
  lipBalm
}

class RoutineStep {
  final StepType type;
  final String name;
  final String? productName;
  final DateTime timestamp;
  final bool isCompleted;
  String? photoUrl;

  RoutineStep({
    required this.type,
    required this.name,
    this.productName,
    required this.timestamp,
    this.isCompleted = false,
    this.photoUrl,
  });

  factory RoutineStep.fromType(StepType type) {
    final now = DateTime.now();
    String name;
    String? defaultProduct;

    switch (type) {
      case StepType.cleanser:
        name = 'Cleanser';
        defaultProduct = 'Cetaphil Gentle Skin Cleanser';
        break;
      case StepType.toner:
        name = 'Toner';
        defaultProduct = 'Thayers Witch Hazel Toner';
        break;
      case StepType.moisturizer:
        name = 'Moisturizer';
        defaultProduct = 'Kiehl\'s Ultra Facial Cream';
        break;
      case StepType.sunscreen:
        name = 'Sunscreen';
        defaultProduct = 'Supergoop Unseen Sunscreen SPF 40';
        break;
      case StepType.lipBalm:
        name = 'Lip Balm';
        defaultProduct = 'Glossier Birthday Balm Dotcom';
        break;
    }

    return RoutineStep(
      type: type,
      name: name,
      productName: defaultProduct,
      timestamp: now,
      isCompleted: false,
    );
  }

  RoutineStep copyWith({
    StepType? type,
    String? name,
    String? productName,
    DateTime? timestamp,
    bool? isCompleted,
    String? photoUrl,
  }) {
    return RoutineStep(
      type: type ?? this.type,
      name: name ?? this.name,
      productName: productName ?? this.productName,
      timestamp: timestamp ?? this.timestamp,
      isCompleted: isCompleted ?? this.isCompleted,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'name': name,
      'productName': productName,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'photoUrl': photoUrl,
    };
  }

  factory RoutineStep.fromMap(Map<String, dynamic> map) {
    return RoutineStep(
      type: StepType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => StepType.cleanser,
      ),
      name: map['name'] ?? '',
      productName: map['productName'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isCompleted: map['isCompleted'] ?? false,
      photoUrl: map['photoUrl'],
    );
  }
}


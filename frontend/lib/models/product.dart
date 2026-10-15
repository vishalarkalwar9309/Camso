class Product {
  final String id, name, pid, category, categoryName, size, description, image;
  final String plyRating, treadDepth, loadIndex, maxLoad, maxSpeed;
  final List<String> features, applications, compatibleEquipment;
  final Map<String, String> specifications;
  final bool isNew, isFeatured, isDiscontinued;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.name,
    required this.pid,
    required this.category,
    required this.categoryName,
    required this.size,
    required this.plyRating,
    required this.treadDepth,
    required this.loadIndex,
    required this.maxLoad,
    required this.maxSpeed,
    required this.description,
    required this.features,
    required this.applications,
    required this.compatibleEquipment,
    required this.specifications,
    required this.image,
    required this.isNew,
    required this.isFeatured,
    this.isDiscontinued = false,
    required this.rating,
    required this.reviewCount,
  });

  Product copyWith({
    String? id,
    String? name,
    String? pid,
    String? category,
    String? categoryName,
    String? size,
    String? plyRating,
    String? treadDepth,
    String? loadIndex,
    String? maxLoad,
    String? maxSpeed,
    String? description,
    List<String>? features,
    List<String>? applications,
    List<String>? compatibleEquipment,
    Map<String, String>? specifications,
    String? image,
    bool? isNew,
    bool? isFeatured,
    bool? isDiscontinued,
    double? rating,
    int? reviewCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      pid: pid ?? this.pid,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      size: size ?? this.size,
      plyRating: plyRating ?? this.plyRating,
      treadDepth: treadDepth ?? this.treadDepth,
      loadIndex: loadIndex ?? this.loadIndex,
      maxLoad: maxLoad ?? this.maxLoad,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      description: description ?? this.description,
      features: features ?? this.features,
      applications: applications ?? this.applications,
      compatibleEquipment: compatibleEquipment ?? this.compatibleEquipment,
      specifications: specifications ?? this.specifications,
      image: image ?? this.image,
      isNew: isNew ?? this.isNew,
      isFeatured: isFeatured ?? this.isFeatured,
      isDiscontinued: isDiscontinued ?? this.isDiscontinued,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final specs = <String, String>{};
    if (json['specifications'] is List) {
      for (final s in (json['specifications'] as List)) {
        if (s is Map) {
          final k = s['spec_key'] ?? s['key'] ?? s['specKey'] ?? s['name'];
          final v = s['spec_value'] ?? s['value'] ?? s['specValue'];
          if (k != null && v != null) {
            final unit = s['unit'];
            final valStr = (unit != null && unit.toString().trim().isNotEmpty)
                ? '${v.toString().trim()} ${unit.toString().trim()}'.trim()
                : v.toString().trim();
            specs[k.toString().trim()] = valStr;
          }
        }
      }
    } else if (json['specifications'] is Map) {
      (json['specifications'] as Map).forEach((k, v) {
        if (k != null && v != null) {
          specs[k.toString().trim()] = v.toString().trim();
        }
      });
    }

    String img = '';
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final first = (json['images'] as List).first;
      if (first is Map && first['url'] != null) {
        img = first['url'].toString();
      }
    } else if (json['image'] is Map && json['image']['url'] != null) {
      img = json['image']['url'].toString();
    } else if (json['image'] != null) {
      img = json['image'].toString();
    }

    String? getSpec(List<String> candidateKeys) {
      for (final ck in candidateKeys) {
        for (final entry in specs.entries) {
          final normalizedEntry = entry.key.toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
          final normalizedCandidate = ck.toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
          if (normalizedEntry == normalizedCandidate) {
            return entry.value;
          }
        }
      }
      return null;
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      pid: json['pid']?.toString() ?? '',
      category: json['category_id']?.toString() ??
          (json['category'] is Map
              ? (json['category']['id']?.toString() ?? json['category']['slug']?.toString() ?? '')
              : json['category']?.toString() ?? ''),
      categoryName: json['category'] is Map
          ? (json['category']['name']?.toString() ?? '')
          : (json['categoryName']?.toString() ?? ''),
      size: getSpec(['Size', 'size', 'tire_size']) ?? json['size']?.toString() ?? 'Standard',
      plyRating: getSpec(['Ply Rating', 'ply_rating', 'plyRating']) ?? json['plyRating']?.toString() ?? 'N/A',
      treadDepth: getSpec(['Tread Depth', 'tread_depth', 'treadDepth']) ?? json['treadDepth']?.toString() ?? 'N/A',
      loadIndex: getSpec(['Load Index', 'load_index', 'loadIndex']) ?? json['loadIndex']?.toString() ?? 'N/A',
      maxLoad: getSpec(['Max Load', 'max_load', 'maxLoad']) ?? json['maxLoad']?.toString() ?? 'N/A',
      maxSpeed: getSpec(['Max Speed', 'max_speed', 'maxSpeed']) ?? json['maxSpeed']?.toString() ?? 'N/A',
      description: json['description']?.toString() ?? '',
      features: (json['features'] is List) ? List<String>.from(json['features']) : const [],
      applications: (json['applications'] is List) ? List<String>.from(json['applications']) : const [],
      compatibleEquipment: (json['compatibleEquipment'] is List)
          ? List<String>.from(json['compatibleEquipment'])
          : const [],
      specifications: specs,
      image: img.isNotEmpty ? img : 'assets/images/camso_default.png',
      isNew: json['isNew'] == true || json['is_new'] == true,
      isFeatured: json['isFeatured'] == true || json['is_featured'] == true,
      isDiscontinued: json['is_active'] == false || json['isDiscontinued'] == true,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.8,
      reviewCount: (json['reviewCount'] is num) ? (json['reviewCount'] as num).toInt() : 12,
    );
  }
}

class AppNotification {
  final String id, type, title, body, date, icon;
  final bool isRead;
  final String? productId, documentId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.date,
    required this.isRead,
    required this.icon,
    this.productId,
    this.documentId,
  });

  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? date,
    bool? isRead,
    String? icon,
    String? productId,
    String? documentId,
  }) =>
      AppNotification(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        date: date ?? this.date,
        isRead: isRead ?? this.isRead,
        icon: icon ?? this.icon,
        productId: productId ?? this.productId,
        documentId: documentId ?? this.documentId,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawType = json['notification_type']?.toString() ?? json['type']?.toString() ?? 'SYSTEM';
    String iconName = 'notifications';
    if (rawType.contains('PRODUCT') || rawType.contains('CATALOGUE')) iconName = 'inventory_2';
    if (rawType.contains('WARRANTY') || rawType.contains('SUPPORT')) iconName = 'verified_user';
    if (rawType.contains('PROMOTION') || rawType.contains('CAMPAIGN')) iconName = 'campaign';

    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: rawType,
      title: json['title']?.toString() ?? 'CAMSO Update',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      date: json['created_at']?.toString().split('T').first ?? json['date']?.toString() ?? 'Today',
      isRead: json['is_read'] == true || json['isRead'] == true,
      icon: json['icon']?.toString() ?? iconName,
      productId: json['product_id']?.toString() ?? json['productId']?.toString(),
      documentId: json['document_id']?.toString() ?? json['documentId']?.toString(),
    );
  }
}


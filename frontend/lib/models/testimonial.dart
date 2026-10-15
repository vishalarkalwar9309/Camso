class Testimonial {
  final String id;
  final String type;
  final String title;
  final String company;
  final String location;
  final String contact;
  final String avatar;
  final String coverImage;
  final String excerpt;
  final String content;
  final String? productId;
  final double rating;
  final String date;
  final List<String> tags;
  final bool isFeatured;

  const Testimonial({
    required this.id,
    required this.type,
    required this.title,
    required this.company,
    required this.location,
    required this.contact,
    required this.avatar,
    required this.coverImage,
    required this.excerpt,
    required this.content,
    required this.productId,
    required this.rating,
    required this.date,
    required this.tags,
    required this.isFeatured,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    final mediaAsset = json['media_asset'];
    String imageUrl = 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800';
    if (mediaAsset is Map && mediaAsset['url'] != null) {
      imageUrl = mediaAsset['url'].toString();
    } else if (json['coverImage'] != null) {
      imageUrl = json['coverImage'].toString();
    } else if (json['image_url'] != null) {
      imageUrl = json['image_url'].toString();
    }

    final rawType = json['story_type']?.toString() ?? json['type']?.toString() ?? 'Customer Story';
    String displayType = rawType;
    if (rawType == 'SOLIDS' || rawType == 'CUSTOMER_STORY') displayType = 'Customer Story';
    if (rawType == 'OPERATING_COST') displayType = 'Product Story';
    if (rawType == 'WORN_PRODUCT_REPLACEMENT') displayType = 'Replacement Story';
    if (rawType == 'REPEAT_PURCHASE') displayType = 'Customer Story';

    final textContent = json['content']?.toString() ?? json['comment']?.toString() ?? '';
    final excerptStr = json['excerpt']?.toString() ??
        (textContent.length > 120 ? '${textContent.substring(0, 117)}...' : textContent);

    final personName = json['contact']?.toString() ?? json['customer_name']?.toString() ?? json['author_name']?.toString();

    return Testimonial(
      id: json['id']?.toString() ?? '',
      type: displayType,
      title: json['title']?.toString() ?? personName ?? 'Customer Experience',
      company: json['company']?.toString() ?? json['company_name']?.toString() ?? json['region']?.toString() ?? 'Construction Partner',
      location: json['location']?.toString() ?? json['region']?.toString() ?? 'Global',
      contact: personName ?? 'Verified Operator',
      avatar: json['avatar']?.toString() ?? imageUrl,
      coverImage: imageUrl,
      excerpt: excerptStr,
      content: textContent,
      productId: json['product_id']?.toString() ?? json['productId']?.toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 5.0,
      date: json['created_at']?.toString().split('T').first ?? json['date']?.toString() ?? '2026',
      tags: json['tags'] is List ? List<String>.from(json['tags'] as List) : <String>['Verified'],
      isFeatured: json['is_featured'] == true || json['isFeatured'] == true,
    );
  }
}
/// Data model representing a frequently asked question.
class FAQItem {
  final String id;
  final String category;
  final String question;
  final String answer;

  const FAQItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      question: json['question']?.toString() ?? json['title']?.toString() ?? '',
      answer: json['answer']?.toString() ?? json['content']?.toString() ?? '',
    );
  }
}


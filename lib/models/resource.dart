/// Mirrors the `Resource` type from the original Next.js website
/// (src/types/index.ts) so Firestore documents are read identically.
class Resource {
  final String id;
  final String title;
  final String description;
  final String category; // 'Question Bank' | 'Textbook Solutions' | 'Study Notes' | 'Video Tutorial' | 'AI'
  final String subject; // 'Physics' | 'Chemistry' | 'Mathematics' | 'Biology' | 'History' | 'Computer Science'
  final String content;
  final String imageUrl;
  final String imageHint;
  final String studentClass; // 'class11' | 'class12'  (renamed from `class` - reserved word in Dart)
  final String stream; // 'NEET' | 'JEE' | 'MHT-CET' | 'General'
  final String? pdfUrl;
  final String? downloadUrl;
  final bool isDownloadable;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subject,
    required this.content,
    required this.imageUrl,
    required this.imageHint,
    required this.studentClass,
    required this.stream,
    this.pdfUrl,
    this.downloadUrl,
    required this.isDownloadable,
  });

  factory Resource.fromMap(String id, Map<String, dynamic> map) {
    return Resource(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Study Notes',
      subject: map['subject'] ?? 'General',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      imageHint: map['imageHint'] ?? '',
      studentClass: map['class'] ?? 'class11',
      stream: map['stream'] ?? 'General',
      pdfUrl: map['pdfUrl'],
      downloadUrl: map['downloadUrl'],
      isDownloadable: map['isDownloadable'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'subject': subject,
      'content': content,
      'imageUrl': imageUrl,
      'imageHint': imageHint,
      'class': studentClass,
      'stream': stream,
      'pdfUrl': pdfUrl,
      'downloadUrl': downloadUrl,
      'isDownloadable': isDownloadable,
    };
  }
}

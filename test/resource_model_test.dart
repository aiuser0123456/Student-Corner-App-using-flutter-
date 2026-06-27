import 'package:flutter_test/flutter_test.dart';
import 'package:student_corner/models/resource.dart';

void main() {
  group('Resource model', () {
    test('fromMap parses a Firestore-style document correctly', () {
      final resource = Resource.fromMap('abc123', {
        'title': 'Newton\'s Laws',
        'description': 'A summary of motion laws',
        'category': 'Study Notes',
        'subject': 'Physics',
        'content': 'Content goes here',
        'imageUrl': 'https://example.com/image.png',
        'imageHint': 'physics diagram',
        'class': 'class11',
        'stream': 'JEE',
        'pdfUrl': 'https://example.com/file.pdf',
        'downloadUrl': null,
        'isDownloadable': false,
      });

      expect(resource.id, 'abc123');
      expect(resource.title, "Newton's Laws");
      expect(resource.category, 'Study Notes');
      expect(resource.studentClass, 'class11');
      expect(resource.stream, 'JEE');
      expect(resource.isDownloadable, false);
    });

    test('fromMap falls back to defaults for missing fields', () {
      final resource = Resource.fromMap('id1', {});
      expect(resource.title, '');
      expect(resource.category, 'Study Notes');
      expect(resource.studentClass, 'class11');
      expect(resource.stream, 'General');
      expect(resource.isDownloadable, false);
    });

    test('toMap round-trips correctly', () {
      final resource = Resource(
        id: 'id2',
        title: 'Test',
        description: 'Desc',
        category: 'Question Bank',
        subject: 'Mathematics',
        content: 'Body',
        imageUrl: '',
        imageHint: '',
        studentClass: 'class12',
        stream: 'NEET',
        isDownloadable: true,
      );
      final map = resource.toMap();
      expect(map['class'], 'class12');
      expect(map['stream'], 'NEET');
      expect(map['isDownloadable'], true);
    });
  });
}

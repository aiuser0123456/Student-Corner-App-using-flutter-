import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/resources_provider.dart';

const kCategories = [
  'Question Bank',
  'Textbook Solutions',
  'Study Notes',
  'Video Tutorial',
  'AI',
];
const kSubjects = [
  'Physics',
  'Chemistry',
  'Mathematics',
  'Biology',
  'History',
  'Computer Science',
];
const kClasses = ['class11', 'class12'];
const kStreams = ['NEET', 'JEE', 'MHT-CET', 'General'];

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? category;
  late String? subject;
  late String? studentClass;
  late String? stream;

  @override
  void initState() {
    super.initState();
    final p = context.read<ResourcesProvider>();
    category = p.selectedCategory;
    subject = p.selectedSubject;
    studentClass = p.selectedClass;
    stream = p.selectedStream;
  }

  Widget _chipGroup(String label, List<String> options, String? selected,
      void Function(String?) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) {
            final isSelected = selected == o;
            return ChoiceChip(
              label: Text(o == 'class11'
                  ? 'Class 11'
                  : o == 'class12'
                      ? 'Class 12'
                      : o),
              selected: isSelected,
              onSelected: (_) => onSelect(isSelected ? null : o),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Filter Resources',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      category = null;
                      subject = null;
                      studentClass = null;
                      stream = null;
                    }),
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _chipGroup('Category', kCategories, category,
                        (v) => setState(() => category = v)),
                    _chipGroup('Subject', kSubjects, subject,
                        (v) => setState(() => subject = v)),
                    _chipGroup('Class', kClasses, studentClass,
                        (v) => setState(() => studentClass = v)),
                    _chipGroup('Stream', kStreams, stream,
                        (v) => setState(() => stream = v)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ResourcesProvider>().setFilters(
                        category: category,
                        subject: subject,
                        studentClass: studentClass,
                        stream: stream,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Apply filters'),
              ),
            ],
          ),
        );
      },
    );
  }
}

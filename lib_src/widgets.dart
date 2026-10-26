import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';
import 'state.dart';
import 'lang.dart';

const Color primaryGreen = Color(0xFF168653);
const Color lightGreen = Color(0xFFE7F6ED);
const Color pageBg = Color(0xFFF6F8F7);
const Color darkText = Color(0xFF18231D);
const Color mutedText = Color(0xFF7D8982);

Color priorityColor(String p) {
  switch (p) {
    case 'high':
      return Colors.red;
    case 'low':
      return Colors.blueGrey;
    default:
      return Colors.orange;
  }
}

String priorityLabel(String p) {
  switch (p) {
    case 'high':
      return 'জরুরি';
    case 'low':
      return 'কম জরুরি';
    default:
      return 'মাঝারি';
  }
}

class TaskTile extends StatelessWidget {
  final Task task;
  final AppState state;
  const TaskTile({super.key, required this.task, required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.data.language;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.done ? const Color(0xFFD8F0E0) : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: task.done ? lightGreen : pageBg,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            task.done ? Icons.check_circle_rounded : Icons.task_alt_rounded,
            color: task.done ? primaryGreen : mutedText,
            size: 22,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: task.done ? mutedText : null,
            decoration: task.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          [
            if (task.time.isNotEmpty) task.time,
            task.category,
            priorityLabel(task.priority),
            if (task.recurring != 'none')
              task.recurring == 'daily' ? 'প্রতিদিন' : 'সাপ্তাহিক',
            if (task.timeSpentSec > 0)
              '${task.timeSpentSec ~/ 60} মিনিট কাজ',
          ].join(' • '),
          style: const TextStyle(fontSize: 11, color: mutedText),
        ),
        trailing: Checkbox(
          value: task.done,
          activeColor: primaryGreen,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          onChanged: (v) => state.toggleTask(task, v ?? false),
        ),
        onTap: () => showDialog(
          context: context,
          builder: (_) => TaskDetailDialog(task: task, state: state),
        ),
        onLongPress: () => showDialog(
          context: context,
          builder: (_) => TaskEditDialog(task: task, state: state),
        ),
      ),
    );
  }
}

class TaskDetailDialog extends StatefulWidget {
  final Task task;
  final AppState state;
  const TaskDetailDialog({super.key, required this.task, required this.state});
  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  final subCtrl = TextEditingController();
  bool running = false;
  DateTime? startedAt;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return AlertDialog(
      title: Text(task.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(task.imagePath!)),
              ),
            Text('তারিখ: ${task.date}  •  সময়: ${task.time.isEmpty ? 'নির্ধারণ করা হয়নি' : task.time}'),
            Text('ক্যাটাগরি: ${task.category}  •  ${priorityLabel(task.priority)}'),
            Text('এই কাজে সময়: ${task.timeSpentSec ~/ 60} মিনিট'),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    if (running && startedAt != null) {
                      task.timeSpentSec +=
                          DateTime.now().difference(startedAt!).inSeconds;
                      running = false;
                      startedAt = null;
                    } else {
                      running = true;
                      startedAt = DateTime.now();
                    }
                    await widget.state.updateTask(task);
                    setState(() {});
                  },
                  icon: Icon(running ? Icons.stop_rounded : Icons.play_arrow_rounded),
                  label: Text(running ? 'টাইমার বন্ধ করো' : 'টাইমার চালু করো'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final img = await picker.pickImage(
                        source: ImageSource.gallery);
                    if (img == null) return;
                    final dir = await getApplicationDocumentsDirectory();
                    final path =
                        '${dir.path}/${task.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    await File(img.path).copy(path);
                    task.imagePath = path;
                    await widget.state.updateTask(task);
                    setState(() {});
                  },
                  icon: const Icon(Icons.photo_rounded),
                  label: const Text('ছবি যোগ করো'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('সাবটাস্ক',
                style: TextStyle(fontWeight: FontWeight.w700)),
            ...task.subtasks.map((s) => CheckboxListTile(
                  value: s.done,
                  title: Text(s.title),
                  onChanged: (v) async {
                    s.done = v ?? false;
                    await widget.state.updateTask(task);
                    setState(() {});
                  },
                )),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: subCtrl,
                    decoration: const InputDecoration(
                      hintText: 'সাবটাস্ক লিখো',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final t = subCtrl.text.trim();
                    if (t.isEmpty) return;
                    task.subtasks.add(SubTask(title: t));
                    subCtrl.clear();
                    await widget.state.updateTask(task);
                    setState(() {});
                  },
                  icon: const Icon(Icons.add_circle_rounded,
                      color: primaryGreen),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('বন্ধ করো'),
        ),
        TextButton(
          onPressed: () async {
            await widget.state.deleteTask(task);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('মুছো', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class TaskEditDialog extends StatefulWidget {
  final Task? task;
  final AppState state;
  final String? initialDate;
  const TaskEditDialog(
      {super.key, this.task, required this.state, this.initialDate});
  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late final titleCtrl =
      TextEditingController(text: widget.task?.title ?? '');
  late String date = widget.task?.date ?? widget.initialDate ?? todayKey();
  late String time = widget.task?.time ?? '';
  late String priority = widget.task?.priority ?? 'medium';
  late String category = widget.task?.category ?? 'কাজ';
  late String recurring = widget.task?.recurring ?? 'none';

  final categories = ['কাজ', 'বাজার', 'পড়া', 'অফিস', 'স্বাস্থ্য', 'বিল', 'পরিকল্পনা', 'হিসাব', 'অন্যান্য'];

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.data.language;
    final isNew = widget.task == null;
    return AlertDialog(
      title: Text(isNew ? tr(lang, 'addTask') : 'কাজ এডিট করো'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: isNew,
              decoration: InputDecoration(
                hintText: tr(lang, 'taskName'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: categories.contains(category) ? category : 'অন্যান্য',
              decoration: const InputDecoration(
                  labelText: 'ক্যাটাগরি', border: OutlineInputBorder()),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => category = v ?? 'কাজ'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: priority,
              decoration: const InputDecoration(
                  labelText: 'প্রায়োরিটি', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'high', child: Text('জরুরি')),
                DropdownMenuItem(value: 'medium', child: Text('মাঝারি')),
                DropdownMenuItem(value: 'low', child: Text('কম জরুরি')),
              ],
              onChanged: (v) => setState(() => priority = v ?? 'medium'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: recurring,
              decoration: const InputDecoration(
                  labelText: 'পুনরাবৃত্তি', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('একবার')),
                DropdownMenuItem(value: 'daily', child: Text('প্রতিদিন')),
                DropdownMenuItem(value: 'weekly', child: Text('সাপ্তাহিক')),
              ],
              onChanged: (v) => setState(() => recurring = v ?? 'none'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('তারিখ: $date')),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: parseKey(date),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setState(() => date = dateKey(picked));
                    }
                  },
                  child: const Text('বদলাও'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Text(
                        'সময়: ${time.isEmpty ? 'নির্ধারণ করা হয়নি' : time}')),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => time =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
                    }
                  },
                  child: const Text('বদলাও'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr(lang, 'cancel')),
        ),
        FilledButton(
          onPressed: () async {
            final title = titleCtrl.text.trim();
            if (title.isEmpty) return;
            if (isNew) {
              final t = Task(
                id: widget.state.newId(),
                title: title,
                date: date,
                time: time,
                priority: priority,
                category: category,
                recurring: recurring,
              );
              await widget.state.addTask(t);
            } else {
              final t = widget.task!;
              t.title = title;
              t.date = date;
              t.time = time;
              t.priority = priority;
              t.category = category;
              t.recurring = recurring;
              await widget.state.updateTask(t);
            }
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr(lang, 'added'))),
              );
            }
          },
          child: Text(isNew ? tr(lang, 'add') : tr(lang, 'save')),
        ),
      ],
    );
  }
}

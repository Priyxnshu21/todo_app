import 'package:flutter/material.dart';
import '../database/notes_database_helper.dart';

class Note {
  String id;
  String title;
  String content;
  DateTime updatedAt;
  String username;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    required this.username,
  });
}

class NotesScreen extends StatefulWidget {
  final String username;
  const NotesScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final db = NotesDatabaseHelper();
    final notes = await db.getNotes(widget.username);
    setState(() {
      _notes = notes;
    });
  }

  void _addOrUpdateNote({int? editIndex}) async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty) return;
    final db = NotesDatabaseHelper();
    if (editIndex == null) {
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        updatedAt: DateTime.now(),
        username: widget.username,
      );
      await db.insertNote(note);
    } else {
      final note = Note(
        id: _notes[editIndex].id,
        title: title,
        content: content,
        updatedAt: DateTime.now(),
        username: widget.username,
      );
      await db.updateNote(note);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    _loadNotes();
  }

  void _deleteNote(int index) async {
    final db = NotesDatabaseHelper();
    await db.deleteNote(_notes[index].id, widget.username);
    _loadNotes();
  }

  void _showNoteDialog({int? editIndex}) {
    if (editIndex != null) {
      _titleController.text = _notes[editIndex].title;
      _contentController.text = _notes[editIndex].content;
    } else {
      _titleController.clear();
      _contentController.clear();
    }
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor:
              theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(editIndex == null ? 'Add Note' : 'Edit Note',
              style: theme.textTheme.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _addOrUpdateNote(editIndex: editIndex),
              child: Text(editIndex == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _showNoteDetailDialog(Note note) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(note.title, style: theme.textTheme.titleLarge),
          content: Text(note.content, style: theme.textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Notes',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () => _showNoteDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Text('No notes yet. Tap Add to create one!',
                        style: theme.textTheme.bodyMedium),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showNoteDetailDialog(note),
                        child: Card(
                          color: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: theme.dividerColor
                                  .withAlpha((0.15 * 255).toInt()),
                              width: 1.2,
                            ),
                          ),
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(note.title,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'Edit',
                                    onPressed: () =>
                                        _showNoteDialog(editIndex: index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Delete',
                                    onPressed: () => _deleteNote(index),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

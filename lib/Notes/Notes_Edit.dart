// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:elect1_todolist/Notes/Notes.dart';
import 'package:elect1_todolist/Notes/NotesServices.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  NoteEditorScreen({this.note});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              final title = _titleController.text.trim();
              final content = _contentController.text.trim();
              if (title.isNotEmpty && content.isNotEmpty) {
                if (widget.note == null) {
                  final newNote = Note(
                    id: _uuid.v4(),
                    title: title,
                    content: content,
                  );
                  await NoteService().addNote(newNote);
                } else {
                  final updatedNote = Note(
                    id: widget.note!.id,
                    title: title,
                    content: content,
                  );
                  await NoteService().updateNote(updatedNote);
                }
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}

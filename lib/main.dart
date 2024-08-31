// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, unused_local_variable

import 'package:elect1_todolist/Notes/Notes.dart';
import 'package:elect1_todolist/Notes/NotesServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Notes(),
  ));
}

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late Future<List<Note>> _notesFuture;
  late List<String> checkedNotes = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _notesFuture = NoteService().getNotes();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      checkedNotes = prefs.getStringList('checked_notes') ?? [];
    });
  }

  Future<void> _refreshNotes() async {
    // Retrieve previously saved checked notes from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? checkedNotes = prefs.getStringList('checked_notes') ?? [];

    setState(() {
      _notesFuture = NoteService().getNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.grey.shade700, // Set background color to amber
    appBar: AppBar(
      backgroundColor: Colors.amber,
      title: Text('To Do List'),
      centerTitle: true,
    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        elevation: 5,
        onPressed: () {
          openProjectBox(context);
        },
        child: Icon(
          Icons.add_box_outlined,
          size: 30,
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10,),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No notes available'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final note = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        child: ListTile(
                          title: Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: checkedNotes.contains(note.id),
                                    onChanged: (newValue) {
                                      setState(() {
                                        if (newValue == true) {
                                          checkedNotes.add(note
                                              .id); // Add note ID to checkedNotes list
                                        } else {
                                          checkedNotes.remove(note
                                              .id); // Remove note ID from checkedNotes list
                                        }
                                        // Save updated checkedNotes list to SharedPreferences
                                        prefs.setStringList(
                                            'checked_notes', checkedNotes);
                                      });
                                    },
                                  ),
                                  Column(
                                    children: [
                                      Text(note.title),
                                      Text(note.content),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Edit') {
                                openProjectBox(context, note: note);
                              } else if (value == 'Delete') {
                                NoteService()
                                    .deleteNote(note.id)
                                    .then((_) => _refreshNotes());
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return {'Edit', 'Delete'}.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void openProjectBox(BuildContext context, {Note? note}) {
    TextEditingController titleController =
        TextEditingController(text: note?.title ?? '');
    TextEditingController contentController =
        TextEditingController(text: note?.content ?? '');
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              note == null ? "Add Notes" : "Edit Notes",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          content: Column(
            children: [
              CupertinoTextField(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                controller: titleController,
                placeholder: 'Title',
                style: TextStyle(color: Colors.black, fontSize: 18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 10),
              CupertinoTextField(
                minLines: null,
                maxLines: null,
                expands: true,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                controller: contentController,
                placeholder: 'Content',
                style: TextStyle(color: Colors.black, fontSize: 18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isNotEmpty && content.isNotEmpty) {
                  if (note == null) {
                    final newNote = Note(
                      id: Uuid().v4(),
                      title: title,
                      content: content,
                    );
                    await NoteService().addNote(newNote);
                  } else {
                    final updatedNote = Note(
                      id: note.id,
                      title: title,
                      content: content,
                    );
                    await NoteService().updateNote(updatedNote);
                  }
                  Navigator.pop(context);
                  _refreshNotes();
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.blueAccent, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}

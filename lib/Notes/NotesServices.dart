// ignore_for_file: file_names

import 'dart:convert';
import 'package:elect1_todolist/Notes/Notes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteService {
  static const String _notesKey = 'notes';

  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString(_notesKey);
    if (notesString != null) {
      final List<dynamic> notesJson = jsonDecode(notesString);
      return notesJson.map((json) => Note.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<Note?> getNoteById(String id) async {
  final notes = await getNotes();
  try {
    return notes.firstWhere((note) => note.id == id);
  } catch (e) {
    return null;
  }
}

  Future<void> addNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();
    notes.add(note);
    final notesString = jsonEncode(notes.map((note) => note.toJson()).toList());
    await prefs.setString(_notesKey, notesString);
  }

  Future<void> updateNote(Note updatedNote) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();
    final index = notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      notes[index] = updatedNote;
      final notesString = jsonEncode(notes.map((note) => note.toJson()).toList());
      await prefs.setString(_notesKey, notesString);
    }
  }

  Future<void> deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();
    final updatedNotes = notes.where((note) => note.id != id).toList();
    final notesString = jsonEncode(updatedNotes.map((note) => note.toJson()).toList());
    await prefs.setString(_notesKey, notesString);
  }
}

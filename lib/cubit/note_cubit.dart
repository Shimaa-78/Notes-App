import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';


part 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  NoteCubit() : super(NoteInitial());

  final notebox = Hive.box("Notes");

  List<Map<String, dynamic>> notesList = [];

  void getNotes() {
    final notes = notebox.toMap();
    notesList = notes.entries.map((entry) {
      final note = entry.value;
      return {
        "key": entry.key,
        "title": note['title'],
        "description": note['description'],
        "date": note['date'],
      };
    }).toList();

    emit(ViewNotes(notesList)); // Emit the loaded state with the notesList
  }
  void addNote({
    required String title,
    required String description,
    required Color color,
  }) {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    notebox.add({
      "title": title,
      "description": description,
      "date": date,
    });
    getNotes(); // Refresh notes
  }

  void deleteNote(int index) async {
    final key = notesList[index]["key"];
    await notebox.delete(key);
      getNotes(); // Refresh notes
  }
  void clearNotes() async {
    await notebox.clear();
    getNotes();
  }
  void updateNote(int index, {
    required String newTitle,
    required String newDescription,
  }) async {
    final key = notesList[index]["key"];
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Auto-add current date

    await notebox.put(key, {
      "title": newTitle,
      "description": newDescription,
      "date": date,
    });
getNotes(); // Refresh notes
  }
}

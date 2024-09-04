part of 'note_cubit.dart';


@immutable
sealed class NoteState {}

final class NoteInitial extends NoteState {}
class ViewNotes extends NoteState {
  final List<Map<String, dynamic>> notesList;

  ViewNotes(this.notesList);
}
class LoadingNotes extends NoteState {}


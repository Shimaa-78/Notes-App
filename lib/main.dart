import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'NotesScreenStateManagment.dart';
import 'cubit/note_cubit.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("Notes");
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NoteCubit()..getNotes(),  // Providing the NoteCubit
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NotesScreenStateManagment(),  // Screen with Bloc state management
      ),
    );
  }
}

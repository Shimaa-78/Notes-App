import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final notebox = Hive.box("Notes");
  List<Map<String, dynamic>> notesList = [];

  // Function to add a new note
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
    getNotes();
  }

  // Function to retrieve notes from the box
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
    setState(() {
    });
  }

  // Function to clear all notes
  void clearNotes() async {
    await notebox.clear();
    getNotes();
  }

  // Function to delete a specific note
  void deleteNote(int index) async {
    final key = notesList[index]["key"];
    await notebox.delete(key);
    getNotes();
  }

  // Function to update a specific note
  void updateNote(int index, {
    required String newTitle,
    required String newDescription,
  }) async {
    final key = notesList[index]["key"];
    final date = DateFormat('yyyy-MM-dd').format(
        DateTime.now()); // Auto-add current date

    await notebox.put(key, {
      "title": newTitle,
      "description": newDescription,
      "date": date,
    });

    getNotes();
  }

  @override
  void initState() {
    getNotes();
    super.initState();
  }

  // Function to display a bottom sheet for note creation
  void _showCreateNoteBottomSheet(Color color) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create New Note",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "Title",
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: "Description",
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty &&
                            descriptionController.text.isNotEmpty) {
                          addNote(
                            title: titleController.text,
                            description: descriptionController.text,
                            color: color,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text("Add Note"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to display a bottom sheet for updating a note
  void _showUpdateNoteBottomSheet(int index) {
    final note = notesList[index];
    final titleController = TextEditingController(text: note["title"]);
    final descriptionController = TextEditingController(
        text: note["description"]);
    final color = getColor(index);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Update Note",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Title",
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: "Description",
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          descriptionController.text.isNotEmpty) {
                        updateNote(
                          index,
                          newTitle: titleController.text,
                          newDescription: descriptionController.text,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Update Note"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: notesList.length,
          itemBuilder: (context, i) {
            return _buildNoteCard(
              notesList[i],
              getColor(i),
              getHeight(i),
              i,
            );
          },
        ),
      ),
      floatingActionButton: _buildCreateButton(),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, Color color, double height,
      int index) {
    return GestureDetector(
      onTap: () => _showUpdateNoteBottomSheet(index),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    note["title"] ?? "Title",
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                  InkWell(
                    onTap: () => deleteNote(index),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                note["description"] ?? "Description",
                style: TextStyle(fontSize: 14, color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    note["date"] ?? "Date",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getColor(int index) {
    List<Color> colors = [
      Color(0xffF8A7AE),
      Color(0xff92BDFC),
      Color(0XFFE9A659),
      Color(0XFFECA7F8),
    ];
    return colors[index % colors.length];
  }

  double getHeight(int index) {
    List<double> heights = [
      120.0,
      150.0,
      180.0,
      210.0,
    ];
    return heights[index % heights.length];
  }

  Widget _buildCreateButton() {
    return InkWell(
      onTap: () => _showCreateNoteBottomSheet(getColor(notesList.length % 4)),
      child: Container(
        width: 130,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xffD39383FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white),
            Text(
              "Create",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white,fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }


  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete All Notes'),
          content: Text(
              'Are you sure you want to delete all notes? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                clearNotes();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: CircleAvatar(
        radius: 80,
        child: CircleAvatar(
          radius: 79,
          child: Image(image: AssetImage("assets/anime-girl-5wx.png")),
        ),
      ),
      title: Text(
        "Your Notes",
        style: TextStyle(
            color: Color(0xffD39383FF), fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_forever, color: Color(0xffD39383FF)),
          onPressed: () {
            _showConfirmDialog();
          },
        ),
      ],
    );
  }
}
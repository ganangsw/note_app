import 'package:flutter/material.dart';
import 'package:note_app/data/db_helper.dart';
import 'package:note_app/page/note_form_page.dart';
import 'package:note_app/page/note_search_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../model/note.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note>? noteList;
  int count = 0;
  int axisCount = 1;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = [];
      updateList();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          noteList?.isEmpty == true
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final Note? result = await showSearch(
                            context: context, delegate: NoteSearchPage(notes: noteList));
                        if (result != null) {
                          navigateToDetail(result, 'Edit Note');
                        }
                      },
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      splashRadius: 22,
                      icon: Icon(
                        axisCount == 2 ? Icons.list : Icons.grid_on,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          axisCount = axisCount == 1 ? 2 : 1;
                        });
                      },
                    ),
                  ],
                )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'Note',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: noteList?.isEmpty == true
                ? Container(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                            'Click on the add button to add a new note!',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.white,
                    child: SingleChildScrollView(child: getNotesList()),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToDetail(Note('', '', 3), 'Add Note'),
        tooltip: 'Add Note',
        shape: const CircleBorder(
          side: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget getNotesList() {
    return StaggeredGrid.count(
      crossAxisCount: axisCount,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      children: List.generate(
        count,
        (index) => GestureDetector(
          onTap: () {
            navigateToDetail(noteList![index], 'Edit Note');
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: getPriorityColor(noteList![index].priority),
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      noteList![index].title,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(noteList![index].description ?? '',
                              style: Theme.of(context).textTheme.bodyLarge),
                        )
                      ],
                    ),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(noteList![index].date,
                        style: Theme.of(context).textTheme.titleSmall),
                  ])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.green;

      default:
        return Colors.yellow;
    }
  }

  void updateList() {
    final Future<Database> dbFuture = databaseHelper.database;
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          count = noteList.length;
        });
      });
    });
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteFormPage(note, title)));

    if (result == true) {
      updateList();
    }
  }
}

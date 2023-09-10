import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app/data/db_helper.dart';
import 'package:note_app/model/note.dart';

import '../utils/priority_picker.dart';

class NoteFormPage extends StatefulWidget {
  const NoteFormPage(this.note, this.appBarTitle, {super.key});

  final String appBarTitle;
  final Note note;

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdited = false;

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.note.title;
    descriptionController.text = widget.note.description ?? "";
    return WillPopScope(
        onWillPop: () async {
          isEdited ? showFormDialog(context) : moveToLastScreen();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              widget.appBarTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            leading: IconButton(
                splashRadius: 22,
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  isEdited ? showFormDialog(context) : moveToLastScreen();
                }),
            actions: [
              IconButton(
                splashRadius: 22,
                icon: const Icon(
                  Icons.save,
                  color: Colors.black,
                ),
                onPressed: () {
                  titleController.text.isEmpty
                      ? showEmptyTitleDialog(context)
                      : _save();
                },
              ),
              widget.note.title != ""
                  ? IconButton(
                      splashRadius: 22,
                      icon: const Icon(Icons.delete, color: Colors.black),
                      onPressed: () {
                        showDeleteDialog(context);
                      },
                    )
                  : const SizedBox.shrink()
            ],
          ),
          body: Column(
            children: [
              PriorityPicker(
                selectedIndex: 3 - widget.note.priority,
                onTap: (index) {
                  isEdited = true;
                  widget.note.priority = 3 - index;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: titleController,
                  maxLength: 255,
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (value) {
                    updateTitle();
                  },
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Title',
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    maxLength: 255,
                    controller: descriptionController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Description',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void showFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Discard Changes?",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          content: Text("Are you sure you want to discard changes?",
              style: Theme.of(context).textTheme.bodyLarge),
          actions: <Widget>[
            TextButton(
              child: Text("No",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
                moveToLastScreen();
              },
            ),
          ],
        );
      },
    );
  }

  void showEmptyTitleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Title is empty!",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          content: Text('The title of the note cannot be empty.',
              style: Theme.of(context).textTheme.bodyLarge),
          actions: [
            TextButton(
              child: Text("Okay",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Delete Note?",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          content: Text("Are you sure you want to delete this note?",
              style: Theme.of(context).textTheme.bodyLarge),
          actions: [
            TextButton(
              child: Text("No",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
                _delete();
              },
            ),
          ],
        );
      },
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateTitle() {
    isEdited = true;
    widget.note.title = titleController.text;
  }

  void updateDescription() {
    isEdited = true;
    widget.note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    widget.note.date = DateFormat.yMMMd().format(DateTime.now());

    if (widget.note.id != null) {
      await _databaseHelper.updateNote(widget.note);
    } else {
      await _databaseHelper.insertNote(widget.note);
    }
  }

  void _delete() async {
    await _databaseHelper.deleteNote(widget.note.id!);
    moveToLastScreen();
  }
}

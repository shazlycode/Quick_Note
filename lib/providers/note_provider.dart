import 'package:flutter/material.dart';
import 'package:keepnote/Helpers/db_helper.dart';

class Note {
  final String? id;
  final String? title;
  final String? content;
  final String? image;
  final Color? color;
  final DateTime? date;

  Note({this.id, this.title, this.content, this.image, this.color, this.date});
}

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [
    // Note(
    //     id: '1',
    //     title: 'First Note',
    //     content:
    //         'First Note Content First Note Content First Note Content First Note Content First Note Content',
    //     color: Colors.red,
    //     image: null,
    //     date: DateTime.now()),
    // Note(
    //     id: '2',
    //     title: 'Second Note',
    //     content: 'Second Note Content Second Note Content',
    //     color: Colors.yellow,
    //     image: null,
    //     date: DateTime.now()),
    // Note(
    //     id: '3',
    //     title: 'Third Note',
    //     content: 'Third Note Content',
    //     color: Colors.green,
    //     image: null,
    //     date: DateTime.now()),
  ];
  List<Note> get notes => [..._notes];

  Future<void> addNote(Note note) async {
    var dateSnapshot = DateTime.now();
    _notes.insert(
        0,
        Note(
            id: dateSnapshot.toString(),
            color: note.color,
            content: note.content,
            date: DateTime.now(),
            image: note.image,
            title: note.title));
    await DBHelper.insertToDB('notes', {
      'id': dateSnapshot.toString(),
      'title': note.title,
      'content': note.content,
      'date': dateSnapshot.toString(),
      'color': note.color!.value,
      'image': note.image == null ? null : note.image!,
    }).then((value) => print('Doneee'));
    // print(_notes.length);
    notifyListeners();
  }

  Future<dynamic> fetchAndSetData(String table) async {
    final data = await DBHelper.getDataBase('notes');
    List<Note> _fetched = [];

    data.forEach((element) {
      _fetched.add(Note(
          id: element['id'],
          title: element['title'],
          color: Color(element['color']),
          content: element['content'],
          image: element['image'],
          date: DateTime.parse(element['date'])));
    });
    // for (int i = 0; i < data.length; i++) {
    //   _fetched.add(Note(
    //       id: data[i]['id'],
    //       title: data[i]['title'],
    //       color: Color(data[i]['color']),
    //       content: data[i]['content'],
    //       image: data[i]['image'],
    //       date: DateTime.parse(data[i]['date'])));
    // }

    _notes = _fetched;
    notifyListeners();
  }

  getNoteById(String id) {
    return _notes.firstWhere((element) => element.id == id);
  }

  Future<dynamic> updateNote(Note note, String id) async {
    var index = _notes.indexWhere((element) => element.id == id);
    _notes[index] = note;
    await DBHelper.updateDB(
        'notes',
        {
          'id': note.id,
          'title': note.title,
          'content': note.content,
          'date': note.date.toString(),
          'color': note.color!.value,
          'image': note.image == null ? null : note.image!,
        },
        id);
    notifyListeners();
  }

  Future<dynamic> deleteNot(String id) async {
    _notes.removeWhere((element) => element.id == id);
    await DBHelper.deleteFromDB(id);
    notifyListeners();
  }

  Future<void> search(String search) async {
    final data = await DBHelper.searchDB(search);
    List<Note> _fetched = [];

    data.forEach((element) {
      _fetched.add(Note(
          id: element['id'],
          title: element['title'],
          color: Color(element['color']),
          content: element['content'],
          image: element['image'],
          date: DateTime.parse(element['date'])));
    });
    _notes = _fetched;
    notifyListeners();
  }
}

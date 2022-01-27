import 'dart:io';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keepnote/Helpers/ad_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:keepnote/providers/note_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:readmore/readmore.dart';

class AddNoteScreen extends StatefulWidget {
  static const String id = 'add_note_screen';
  const AddNoteScreen({Key? key, id}) : super(key: key);

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  File? _storedImage;
  File? _savedImage;
  var note = Note(
      id: null, title: '', content: '', image: null, color: null, date: null);
  Color? _selectedColor;
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.deepPurple,
    Colors.pink
  ];

  Map<String, dynamic> _initialValue = {'title': '', 'content': ''};

  @override
  void didChangeDependencies() {
    final noteId = ModalRoute.of(this.context)!.settings.arguments as String?;
    if (noteId != null) {
      note = this.context.read<NoteProvider>().getNoteById(noteId);
      // Provider.of<NoteProvider>(this.context).getNoteById(noteId);
      _initialValue = {'title': note.title, 'content': note.content};
      _selectedColor = note.color;
      _storedImage = note.image == null ? null : File(note.image!);
      _savedImage = _storedImage;
    } else {
      _initialValue = {'title': '', 'content': ''};
    }
    super.didChangeDependencies();
  }

  final _form = GlobalKey<FormState>();

  _pickImage() async {
    final picker = ImagePicker();
    var pickedImage =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 60);
    File _pickedImage = File(pickedImage!.path);

    setState(() {
      _storedImage = _pickedImage;
    });
    final dir = await path.getApplicationDocumentsDirectory();
    final fileName = basename(pickedImage.path);
    _savedImage = await _pickedImage.copy('${dir.path}/$fileName');
    Navigator.of(this.context).pop();
  }

  _selectImage() async {
    final picker = ImagePicker();
    var pickedImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    File _pickedImage = File(pickedImage!.path);

    setState(() {
      _storedImage = _pickedImage;
    });
    final dir = await path.getApplicationDocumentsDirectory();
    final fileName = basename(pickedImage.path);
    _savedImage = await _pickedImage.copy('${dir.path}/$fileName');
    Navigator.of(this.context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _saveNote() async {
      print('///');
      if (!_form.currentState!.validate()) {
        return;
      }
      _form.currentState!.save();
      if (note.id != null) {
        await context.read<NoteProvider>().updateNote(note, note.id!);
      } else {
        await context.read<NoteProvider>().addNote(note);
      }
      Navigator.pushNamed(context, '/');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).bottomAppBarColor,
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    _saveNote();
                  },
                  icon: const Icon(Icons.save)),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            // height: MediaQuery.of(context).size.height,
            color: _selectedColor,
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_storedImage != null)
                      Container(
                        height: 300,
                        width: double.infinity,
                        child: Image(
                          fit: BoxFit.cover,
                          image: FileImage(_storedImage!),
                        ),
                      ),
                    TextFormField(
                      initialValue: _initialValue['title'],
                      onSaved: (value) {
                        note = Note(
                            id: note.id,
                            color: _selectedColor ?? Colors.grey[850],
                            title: value,
                            content: note.content,
                            date: note.date,
                            image:
                                _savedImage == null ? null : _savedImage!.path);
                      },
                      style: const TextStyle(fontSize: 30),
                      decoration: const InputDecoration(
                          hintText: 'Title',
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none)),
                    ),
                    TextFormField(
                      initialValue: _initialValue['content'],
                      onSaved: (value) {
                        note = Note(
                            id: note.id,
                            color: _selectedColor ?? Colors.grey[850],
                            title: note.title,
                            content: value,
                            date: note.date,
                            image:
                                _savedImage == null ? null : _savedImage!.path);
                      },
                      validator: (v) {
                        if (v!.isEmpty) {
                          return 'Enter note';
                        }
                        return null;
                      },
                      maxLines: 100,
                      decoration: const InputDecoration(
                          hintText: 'Note',
                          helperStyle:
                              TextStyle(fontSize: 20, color: Colors.grey),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none)),
                    ),
                  ],
                ),
              ),
            ),
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        // _showDialog(context);
                        showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            context: context,
                            builder: (ctx) {
                              return SizedBox(
                                height: 200,
                                child: ListView(
                                  children: [
                                    ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: const Text('Take photo'),
                                        onTap: () =>
                                            _pickImage() //_takePicture,
                                        ),
                                    ListTile(
                                        leading:
                                            const Icon(Icons.image_outlined),
                                        title: const Text('Add image'),
                                        onTap: () =>
                                            _selectImage() // _addPicture,
                                        ),
                                  ],
                                ),
                              );
                            });
                      },
                      icon: const Icon(Icons.add_box_outlined)),
                  IconButton(
                      onPressed: () => showModalBottomSheet(
                          context: context,
                          builder: (ctx) {
                            // ignore: avoid_unnecessary_containers
                            return Container(
                              padding: const EdgeInsets.all(5),
                              height: 250,
                              color: _selectedColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    'Colour',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: _colors
                                        .map((e) => GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedColor = e;
                                                });
                                              },
                                              child: Container(
                                                height: 25,
                                                width: 25,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.white),
                                                    color: e,
                                                    shape: BoxShape.circle),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                  const Text(
                                    'Background',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: _colors
                                        .map((e) => GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedColor = e;
                                                });
                                              },
                                              child: Container(
                                                height: 25,
                                                width: 25,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.white),
                                                    color: e,
                                                    shape: BoxShape.circle),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            );
                          }),
                      icon: const Icon(Icons.palette_outlined)),
                ],
              ),
              if (note.date != null)
                Text(
                  'Edited ${DateFormat('dd-MM-yyyy').add_jms().format(note.date!)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontSize: 10),
                ),
              // IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
        ],
      ),
    );
  }

  // _showDialog(BuildContext ctx) {
  //   showDialog(
  //       context: ctx,
  //       builder: (BuildContext ctx) {
  //         return Dialog(
  //           clipBehavior: Clip.antiAlias,
  //           child: ListView(
  //             children: [
  //               ListTile(
  //                   leading: const Icon(Icons.camera_alt),
  //                   title: const Text('Take photo'),
  //                   onTap: () => _pickImage() //_takePicture,
  //                   ),
  //               // ListTile(
  //               //     leading: const Icon(Icons.image_outlined),
  //               //     title: const Text('Add image'),
  //               //     onTap: () => _selectImage() // _addPicture,
  //               //     ),
  //             ],
  //           ),
  //         );
  //       });
  // }

}

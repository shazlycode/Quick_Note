import 'dart:io';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';
import 'package:flutter/material.dart';
import 'package:keepnote/providers/note_provider.dart';
import 'package:intl/intl.dart';
import 'package:keepnote/screens/add_note_screen.dart';
import 'package:provider/provider.dart';

class NoteDetails extends StatefulWidget {
  static const String id = 'note_detail_screen';
  const NoteDetails({Key? key}) : super(key: key);

  @override
  _NoteDetailsState createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  final _contentTextField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final note = ModalRoute.of(context)!.settings.arguments as Note?;
    _contentTextField.text = note!.content!;
    return Scaffold(
      backgroundColor: note.color,
      body: SafeArea(
          child: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AddNoteScreen.id,
                            arguments: note.id);
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () => Share.share(note.content!),
                      icon: const Icon(MdiIcons.share)),
                  IconButton(
                      onPressed: () {
                        context.read<NoteProvider>().deleteNot(note.id!);
                        Navigator.pushNamed(context, '/');
                      },
                      icon: const Icon(Icons.delete)),
                ],
              ),
              Text(note.title!),
              Text(
                DateFormat('dd-MM-yyyy').add_jm().format(note.date!),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 15),
              ),
              if (note.image != null)
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image(
                    fit: BoxFit.cover,
                    image: FileImage(File(note.image!)),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              Text(
                '${note.content!}\n\n',
                overflow: TextOverflow.visible,
                maxLines: 2000,
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

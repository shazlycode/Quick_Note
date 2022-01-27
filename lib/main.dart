import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:keepnote/providers/note_provider.dart';
import 'package:keepnote/screens/add_note_screen.dart';
import 'package:keepnote/screens/main_screen.dart';
import 'package:keepnote/screens/note_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NoteProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          canvasColor: Colors.black,
          textTheme: const TextTheme(
            bodyText1: TextStyle(color: Colors.white, fontSize: 20),
            bodyText2: TextStyle(
                color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800),
          ),
        ),
        home: const MainScreen(),
        routes: {
          NoteDetails.id: (context) => const NoteDetails(),
          AddNoteScreen.id: (context) => const AddNoteScreen(),
        },
      ),
    );
  }
}

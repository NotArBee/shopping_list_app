import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopping_list/screens/grocery_list.dart';

final theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromARGB(255, 147, 229, 250),
      brightness: Brightness.dark,
      surface: const Color.fromARGB(255, 42, 51, 59),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60),
    textTheme: GoogleFonts.poppinsTextTheme());

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((fn) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: GroceryList(),
    );
  }
}

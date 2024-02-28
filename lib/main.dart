import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'Home.dart';

// Import your FavoriteContact class here

Future<void> main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register the TypeAdapter for FavoriteContact
  // Hive.registerAdapter(FavoriteContactAdapter());

  // Open the Hive box
  await Hive.openBox('favorites');

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(fontFamily: GoogleFonts.poppins().fontFamily),
      home: Home(),
    );
  }
}

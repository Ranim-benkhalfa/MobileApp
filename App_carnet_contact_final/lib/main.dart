import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // pour SQLite sur desktop
import 'app_router.dart'; // notre configuration de routes

void main() {
  // Initialiser SQLite pour desktop (Windows/Mac/Linux)
  sqfliteFfiInit();

  // Définir la factory de database pour FFI
  databaseFactory = databaseFactoryFfi;

  // Lancer l'application
  runApp(const MyApp());
}

// Widget principal de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // enlever le bandeau DEBUG
      title: 'Carnet de Contact',        // titre de l'application
      theme: ThemeData(
        primarySwatch: Colors.pink,      // couleur principale
        useMaterial3: true,              // utiliser Material3
      ),
      routerConfig: AppRouter.router,    // config du router avec GoRouter
    );
  }
}

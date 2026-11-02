import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- 1. Importa o Firebase Core
import 'screens/home_screen.dart';

void main() async { // <-- 2. Adiciona 'async' aqui
  // 3. Garante que os bindings do Flutter estão prontos antes de chamar serviços nativos
  WidgetsFlutterBinding.ensureInitialized();
  
  // 4. Inicializa o Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cubik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
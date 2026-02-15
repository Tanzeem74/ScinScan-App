import 'package:final_project/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9jZ21sa2RocnhlbGJ2bWFrc3dkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcxNTg0NzgsImV4cCI6MjA3MjczNDQ3OH0.3SBtjHqm-zGog014HEHSO9ly-3haN4X-IE2IgDm8Asw',
    url: 'https://ocgmlkdhrxelbvmakswd.supabase.co',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
      ),
      home: AuthGate(),
    );
  }
}

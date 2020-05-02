import 'package:flutter/material.dart';
import 'package:proyectoblog/home_page.dart';

class BlogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Blog App",
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(color: Colors.pink,),
    );
  }
}

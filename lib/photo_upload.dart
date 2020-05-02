import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:proyectoblog/home_page.dart';

class PhotoUpload extends StatefulWidget {
  @override
  _PhotoUploadState createState() => _PhotoUploadState();
}

class _PhotoUploadState extends State<PhotoUpload> {
  File _sampleImage;
  String _description;
  String _imageUrl;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload image"),
        centerTitle: true,
      ),
      body: Center(
        child: _sampleImage == null ? Text("Select an image") : enableUpload(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: "Add Image",
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _sampleImage = tempImage;
    });
  }

  Widget enableUpload() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Image.file(_sampleImage, height: 300, width: 600),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Description"),
                  validator: (value) {
                    return value.isEmpty ? "Description is required" : null;
                  },
                  onSaved: (value) {
                    return _description = value;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                RaisedButton(
                  elevation: 10,
                  child: Text("Add a new Post"),
                  textColor: Colors.white,
                  color: Colors.pink,
                  onPressed: uploadStatusImage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void uploadStatusImage() async {
    if (validateOnSave()) {
      final StorageReference postImgRef =
          FirebaseStorage.instance.ref().child("PostImages");
      var timeKey = DateTime.now();
      final StorageUploadTask uploadTask =
          postImgRef.child(timeKey.toString() + ".jpg").putFile(_sampleImage);
      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      _imageUrl = imageUrl.toString();

      print("Image URL: $imageUrl");

      saveToDatabase(_imageUrl, _description, timeKey);

      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomePage();
        }
      ));
    }
  }

  void saveToDatabase(String url, String description, DateTime timeKey) {
    DatabaseReference ref = FirebaseDatabase.instance.reference();

    var document = {
      "imageUrl": url,
      "description": description,
      "time": timeKey.toString()
    };

    ref.child("Posts").push().set(document);
  }

  bool validateOnSave() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    } else
      return false;
  }
}

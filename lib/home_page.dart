import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyectoblog/photo_upload.dart';
import 'package:proyectoblog/models/post.dart';

class HomePage extends StatefulWidget {
  final Color color;

  HomePage({this.color});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> postList = [];

  @override
  void initState() {
    super.initState();

    DatabaseReference postsRef =
        FirebaseDatabase.instance.reference().child("Posts");

    postsRef.once().then((DataSnapshot dataSnapshot) {
      var keys = dataSnapshot.value.keys;
      var data = dataSnapshot.value;

      postList.clear();

      for (var key in keys) {
        Post post = Post(
          description: data[key]['description'],
          time: DateTime.parse(data[key]['time']),
          imageUrl: data[key]['imageUrl'] ?? "",
        );

        postList.add(post);
      }

      setState(() {
        print("Post list length: ${postList.length.toString()}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
        child: postList.length == 0
            ? Text("No blog available")
            : ListView.builder(
                itemCount: postList.length,
                itemBuilder: (_, index) {
                  return PostsUI(postList[index]);
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: widget.color,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add_a_photo),
                iconSize: 40,
                color: Colors.white,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PhotoUpload();
                  }));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget PostsUI(Post post) {
    var formatDate = DateFormat("MMM d, yyyy");
    var formatTime = DateFormat("EEEE, hh:mm aaa");

    String _date = formatDate.format(post.time);
    String _time = formatTime.format(post.time);

    return Card(
      elevation: 10,
      margin: EdgeInsets.all(14),
      child: Container(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _date,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center,
                ),
                Text(_time),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              post.description,
              style: Theme.of(context).textTheme.subhead,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

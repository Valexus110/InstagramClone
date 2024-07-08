import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/models/post.dart';
import 'package:instagram_example/utils/global_variables.dart';
import 'package:instagram_example/widgets/post_card.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({Key? key}) : super(key: key);

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  var saved = [];

  @override
  void initState() {
    super.initState();
    getSaved();
  }

  void getSaved() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      var postsSnap = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('datePublished', descending: true)
          .get();
      var currSaved = userSnap.data()!['saved'];
      var cnt = 0;
      for (int i = 0; i < postsSnap.docs.length; i++) {
        if (currSaved.length > cnt &&
            postsSnap.docs[i].data()['postId'] == currSaved[cnt]) {
          var data = postsSnap.docs[i].data();
          Post post = Post(
              description: data['description'],
              uid: data['uid'],
              postId: data['postId'],
              username: data['username'],
              datePublished: data['datePublished'],
              postUrl: data['photoUrl'],
              profileImage: data['profileImage'],
              likes: data['likes']);
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('savedPosts')
              .doc(data['postId'])
              .set(post.toJson());
          cnt++;
        } else if (currSaved.length == cnt) {
          break;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "Favourite Posts",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('savedPosts')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('posts')
                .orderBy('datePublished', descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: width > webScreenSize ? width * 0.3 : 0,
                          vertical: width > webScreenSize ? 15 : 0,
                        ),
                        child: PostCard(
                          snap: snapshot.data!.docs[index].data(),
                          savedScreen: true,
                        ),
                      ));
            }));
  }
}

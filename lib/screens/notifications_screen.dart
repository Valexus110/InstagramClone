import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/resources/firestore_methods.dart';
import 'package:instagram_example/screens/profile_screen.dart';
import 'package:instagram_example/widgets/follow_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isLoading = false;
  var followers = [];
  var following = [];

//  var userPhotos = [];
  var userInfo = [];
  var currUid = "";

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      currUid = FirebaseAuth.instance.currentUser!.uid;
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currUid)
          .get();
      followers = userSnap.data()!['followers'];
      following = userSnap.data()!['following'];
      for (var uid in followers) {
        getUserInfo(uid);
      }
      for (var uid in following) {
        getUserInfo(uid);
      }
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  getUserInfo(String uid) async {
    var user =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    for (var uid in user.data()!['followers']) {
      if (!followers.contains(uid) &&
          !following.contains(uid) &&
          uid != currUid) {
        var currUser =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        setState(() {
          if (!userInfo.contains(currUser.data())) {
            userInfo.add(currUser.data());
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Recommendations",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(children: [
        const SizedBox(height: 20),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(children: [
                for (int i = 0; i < userInfo.length; i++)
                  Column(children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                      uid: userInfo[i]['uid'], search: true))),
                          splashFactory: NoSplash.splashFactory,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                NetworkImage(userInfo[i]['photoUrl']),
                            radius: 30,
                          ),
                        ),
                        Column(children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 8),
                            child: Text(
                              userInfo[i]['username'],
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 8),
                            child: Text(
                              userInfo[i]['email'],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ]),
                        FollowButton(
                          func: () async {
                            await FirestoreMethods().followUser(
                                FirebaseAuth.instance.currentUser!.uid,
                                userInfo[i]['uid']);
                          },
                          text: 'Follow',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          borderColor: Colors.grey,
                          divider: 4,
                        )
                      ],
                    ),
                  ]),
              ]),
      ]),
    );
  }
}

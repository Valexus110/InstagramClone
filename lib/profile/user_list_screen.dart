import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/profile/profile_screen.dart';
import 'package:instagram_example/utils/utils.dart';
import 'package:instagram_example/widgets/follow_button.dart';

import '../data/firestore_methods.dart';

class UserListScreen extends StatefulWidget {
  final String? userId;
  final String title;
  final bool? isFollowers;

  const UserListScreen(
      {Key? key,
      this.title = "Users who you might know",
      this.isFollowers,
      this.userId})
      : super(key: key);

  @override
  State<UserListScreen> createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  bool isLoading = false;
  var followers = [];
  var following = [];

//  var userPhotos = [];
  var userInfo = [];

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
      var currUid = widget.userId ?? FirebaseAuth.instance.currentUser!.uid;
      await getUsersInfo(currUid);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  getUsersInfo(String currUid) async {
    var user = await FirebaseFirestore.instance.collection('users').get();
    var userSnap =
        await FirebaseFirestore.instance.collection('users').doc(currUid).get();
    followers = userSnap.data()!['followers'];
    following = userSnap.data()!['following'];
    userInfo.clear();
    Map<String, dynamic>? userData;
    for (var e in user.docs) {
      if (widget.isFollowers == null) {
        if (!followers.contains(e.id) &&
            !following.contains(e.id) &&
            e.id != currUid) {
          userData = e.data();
        }
      } else if (widget.isFollowers != null && widget.isFollowers == true) {
        if (followers.contains(e.id)) {
          userData = e.data();
        }
      } else if (widget.isFollowers != null && widget.isFollowers == false) {
        if (following.contains(e.id)) {
          userData = e.data();
        }
      }
      if (userData != null) {
        setState(() {
          userInfo.add(userData);
        });
        userData = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(children: [
        const SizedBox(height: 20),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : userInfo.isEmpty
                ? const Center(child: Text("No users found"))
                : Column(children: [
                    for (int i = 0; i < userInfo.length; i++)
                      Column(children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                          uid: userInfo[i]['uid'])))
                                  .then((value) async => await getData()),
                              splashFactory: NoSplash.splashFactory,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    NetworkImage(userInfo[i]['photoUrl']),
                                radius: 30,
                              ),
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 8),
                                    child: Text(
                                      userInfo[i]['username'],
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 8),
                                    child: Text(
                                      userInfo[i]['email'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ]),
                            const Spacer(),
                            widget.isFollowers == false
                                ? FollowButton(
                                    func: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await FirestoreMethods().followUser(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          userInfo[i]['uid']);
                                      var name = userInfo[i]['username'];
                                      userInfo.removeAt(i);
                                      if (!context.mounted) return;
                                      showSnackBar(context,
                                          "successfully followed $name");
                                      await getData();
                                    },
                                    text: widget.isFollowers == false
                                        ? 'Unfollow'
                                        : "Follow",
                                    isFollow: widget.isFollowers != false,
                                    divider: 4,
                                  )
                                : Container(),
                          ],
                        ),
                      ]),
                  ]),
      ]),
    );
  }
}

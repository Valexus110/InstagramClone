import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/resources/auth_methods.dart';
import 'package:instagram_example/resources/firestore_methods.dart';
import 'package:instagram_example/screens/login_screen.dart';
import 'package:instagram_example/screens/saved_posts_screen.dart';
import 'package:instagram_example/screens/user_list_screen.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:instagram_example/utils/utils.dart';
import 'package:instagram_example/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late var _editingController = TextEditingController();
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      if (!mounted) return;
      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userData['followers'].length;
      following = userData['following'].length;
      isFollowing = userData['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        isLoading = true;
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _editingController = TextEditingController();
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home)),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SavedPostsScreen()));
                    },
                    icon: const Icon(Icons.star)),
              ],
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData['photoUrl']),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStartColumn(postLen, "Posts"),
                                    buildStartColumn(followers, "Followers"),
                                    buildStartColumn(following, "Following"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    (widget.uid ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid)
                                        ? FollowButton(
                                            func: () async {
                                              await AuthMethods().signOut();
                                              if (!mounted) return;
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginScreen()));
                                            },
                                            text: 'Sign Out',
                                            isFollow: false,
                                            divider: 2,
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                func: () async {
                                                  await FirestoreMethods()
                                                      .followUser(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                          userData['uid']);
                                                  setState(() {
                                                    isFollowing = false;
                                                    followers--;
                                                  });
                                                },
                                                text: 'Unfollow',
                                                isFollow: false,
                                                divider: 2,
                                              )
                                            : FollowButton(
                                                func: () async {
                                                  await FirestoreMethods()
                                                      .followUser(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                          userData['uid']);
                                                  setState(() {
                                                    isFollowing = true;
                                                    followers++;
                                                  });
                                                },
                                                text: 'Follow',
                                                isFollow: true,
                                                divider: 2,
                                              )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          userData['email'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 10),
                        child: TextButton(
                          onPressed: FirebaseAuth.instance.currentUser!.uid !=
                                  widget.uid
                              ? null
                              : changeBio,
                          child: Text(userData['bio'],
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .where('uid', isEqualTo: widget.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return GridView.builder(
                          shrinkWrap: true,
                          itemCount: (snapshot.data! as dynamic).docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 1.5,
                                  childAspectRatio: 1),
                          itemBuilder: (context, index) {
                            DocumentSnapshot snap =
                                (snapshot.data! as dynamic).docs[index];
                            return Image(
                              image: NetworkImage(snap['postUrl']),
                              fit: BoxFit.cover,
                            );
                          });
                    }),
              ],
            ),
          );
  }

  void changeBio() {
    _editingController = TextEditingController(text: userData['bio']);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 16,
          child: TextField(
            decoration: const InputDecoration(
              border: InputBorder.none,
              fillColor: Colors.white70,
              contentPadding: EdgeInsets.all(10.0),
            ),
            onSubmitted: (newBio) {
              setState(() {
                FirestoreMethods()
                    .changeBio(FirebaseAuth.instance.currentUser!.uid, newBio);
                getData();
                Navigator.pop(context);
              });
            },
            autofocus: true,
            controller: _editingController,
          ),
        );
      },
    );
  }

  buildStartColumn(int num, String label) {
    return GestureDetector(
      onTap: () => {
        if (label != "Posts" && num > 0)
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserListScreen(
                  userId: widget.uid,
                  title: label,
                  isFollowers: label == "Followers")))
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(num.toString(),
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

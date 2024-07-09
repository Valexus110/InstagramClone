import 'package:flutter/material.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart';
import 'package:instagram_example/common/common_controller.dart';
import 'package:instagram_example/posts/ui/saved_posts_screen.dart';
import 'package:instagram_example/profile/ui/profile_controller.dart';
import 'package:instagram_example/users_recommendation/ui/user_list_screen.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:instagram_example/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:instagram_example/models/user.dart' as model;

import '../../authentication/ui/login_screen.dart';
import '../../common/widgets/follow_button.dart';
import '../../models/post.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late var _editingController = TextEditingController();
  late model.User userData;
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  final _commonController = CommonController();
  final _profileController = ProfileController();
  late final String currentUid;

  @override
  void initState() {
    super.initState();
    currentUid = Provider.of<AuthProvider>(context, listen: false).getUserId();
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
      userData = await _profileController.getUserInfo(widget.uid);
      postLen = await _profileController.getPostInfo(widget.uid);
      if (!mounted) return;
      followers = userData.followers.length;
      following = userData.followers.length;
      isFollowing = userData.followers.contains(currentUid);
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
                userData.username,
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
                            backgroundImage: NetworkImage(userData.photoUrl),
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
                                    (widget.uid == currentUid)
                                        ? FollowButton(
                                            func: () async {
                                              await Provider.of<AuthProvider>(
                                                      context,
                                                      listen: false)
                                                  .signOut();
                                              if (!context.mounted) return;
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
                                                  _commonController.followUser(
                                                      currentUid, userData.uid);
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
                                                  await _commonController
                                                      .followUser(currentUid,
                                                          userData.uid);
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
                          userData.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 10),
                        child: TextButton(
                          onPressed:
                              currentUid != widget.uid ? null : changeBio,
                          child: Text(userData.bio,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                    future: _profileController.getUserPosts(widget.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return GridView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 1.5,
                                  childAspectRatio: 1),
                          itemBuilder: (context, index) {
                            Post snap = snapshot.data![index];
                            return Image(
                              image: NetworkImage(snap.postUrl),
                              fit: BoxFit.cover,
                            );
                          });
                    }),
              ],
            ),
          );
  }

  void changeBio() {
    _editingController = TextEditingController(text: userData.bio);
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
                _profileController.changeBio(currentUid, newBio);
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

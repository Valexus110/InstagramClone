import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/profile/ui/profile_screen.dart';
import 'package:instagram_example/users_recommendation/ui/recommendation_controller.dart';
import 'package:instagram_example/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../authentication/ui/auth_provider.dart';
import '../../common/common_controller.dart';
import '../../common/widgets/follow_button.dart';

import 'package:instagram_example/models/user.dart' as model;

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

  var userInfo = <model.User>[];
  final _commonController = CommonController();
  final _recommendationController = RecommendationController();
  late final String currentUid;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    currentUid = Provider.of<AuthProvider>(context, listen: false).getUserId();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var currUid = widget.userId ?? currentUid;
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
    var userSnap = model.User.fromJson(
        await _recommendationController.getFollowed(currUid));
    if (!mounted) return;
    setState(() {
      followers = userSnap.followers;
      following = userSnap.following;
    });
    var userData = await _recommendationController.getUserInfo(
        widget.isFollowers, currUid, following, followers);
    if (!mounted) return;
    setState(() {
      userInfo.clear();
      userInfo = userData;
    });
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
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                          key: _scaffoldKey,
                                          uid: userInfo[i].uid)))
                                  .then((value) async => await getData()),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    NetworkImage(userInfo[i].photoUrl),
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
                                      userInfo[i].username,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 8),
                                    child: Text(
                                      userInfo[i].email,
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
                                      await _commonController.followUser(
                                          currentUid, userInfo[i].uid);
                                      var name = userInfo[i].username;
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

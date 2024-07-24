import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
import '../../coordinate_layout/page_provider.dart';
import '../../models/post.dart';
import '../../storage/storage_controller.dart';

class ProfileScreen extends StatefulWidget {
  final GlobalKey? scaffoldKey;
  final String? uid;

  const ProfileScreen({super.key, this.uid, this.scaffoldKey});

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
  bool isUpdateLoading = false;
  bool isFollowButtonLoading = false;
  final _commonController = CommonController();
  final _profileController = ProfileController();
  final _storageController = StorageController();
  AuthProvider authProvider = AuthProvider();
  late String userUid;
  late String currentUid;
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    userUid = Provider.of<AuthProvider>(context, listen: false).getUserId();
    getData();
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  getData() async {
    setState(() {
      if (widget.uid == null) {
        currentUid = userUid;
      } else {
        currentUid = widget.uid!;
      }
      isLoading = true;
    });
    try {
      userData = await _profileController.getUserInfo(currentUid);
      postLen = await _profileController.getPostInfo(currentUid);
      if (!mounted) return;
      followers = userData.followers.length;
      following = userData.following.length;
      isFollowing = userData.followers.contains(userUid);
      Provider.of<AuthProvider>(context, listen: false).refreshUser();
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

  Future<Uint8List?> _selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    return im;
  }

  @override
  Widget build(BuildContext context) {
    _editingController = TextEditingController();
    authProvider = Provider.of(context);
    final pageProvider = Provider.of<PageProvider>(context);
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            key: widget.scaffoldKey,
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
                      pageProvider.pageSelection.jumpToPage(0);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home)),
                userUid == currentUid
                    ? IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SavedPostsScreen()));
                        },
                        icon: const Icon(Icons.star))
                    : Container()
              ],
              centerTitle: false,
            ),
            body: RefreshIndicator.adaptive(
              onRefresh: () async {
                await getData();
              },
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                      (userUid == currentUid)
                                          ? FollowButton(
                                              func: () async {
                                                setState(() {
                                                  isFollowButtonLoading = true;
                                                });
                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 500));
                                                await authProvider.signOut();
                                                if (!context.mounted) return;
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const LoginScreen()));
                                              },
                                              text: 'Sign Out',
                                              isButtonLoading:
                                                  isFollowButtonLoading,
                                              isFollow: false,
                                              divider: 2,
                                            )
                                          : isFollowing
                                              ? FollowButton(
                                                  func: () async {
                                                    setState(() {
                                                      isFollowButtonLoading =
                                                          true;
                                                    });
                                                    await _commonController
                                                        .followUser(userUid,
                                                            currentUid);
                                                    setState(() {
                                                      isFollowing = false;
                                                      followers--;
                                                      isFollowButtonLoading =
                                                          false;
                                                    });
                                                  },
                                                  text: 'Unfollow',
                                                  isFollow: false,
                                                  isButtonLoading:
                                                      isFollowButtonLoading,
                                                  divider: 2,
                                                )
                                              : FollowButton(
                                                  func: () async {
                                                    setState(() {
                                                      isFollowButtonLoading =
                                                          true;
                                                    });
                                                    await _commonController
                                                        .followUser(userUid,
                                                            currentUid);
                                                    setState(() {
                                                      isFollowing = true;
                                                      followers++;
                                                      setState(() {
                                                        isFollowButtonLoading =
                                                            false;
                                                      });
                                                    });
                                                  },
                                                  text: 'Follow',
                                                  isFollow: true,
                                                  isButtonLoading:
                                                      isFollowButtonLoading,
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
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Text(
                                userData.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              currentUid == userUid
                                  ? TextButton(
                                      onPressed: changeProfileInfo,
                                      child: const Text("Edit profile"))
                                  : Container(),
                            ],
                          ),
                        ),
                        currentUid != userUid
                            ? const SizedBox(
                                height: 8,
                              )
                            : Container(),
                        Text(userData.bio,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white)),
                      ],
                    ),
                  ),
                  const Divider(),
                  FutureBuilder(
                      future: _profileController.getUserPosts(currentUid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
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
            ),
          );
  }

  void changeProfileInfo() {
    var bioEditingController = TextEditingController(text: userData.bio);
    var nameEditingController = TextEditingController(text: userData.username);
    setState(() {
      _image = null;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 16,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 32, bottom: 32, left: 16.0, right: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    _image == null
                        ? CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(userData.photoUrl),
                          )
                        : CircleAvatar(
                            radius: 32,
                            backgroundImage: MemoryImage(_image!),
                          ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextButton(
                      onPressed: () async {
                        var im = await _selectImage();
                        setState(() {
                          _image = im;
                          // isImageLoading = false;
                        });
                      },
                      child: const Text("Change profile photo"),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    customTextField(
                        nameEditingController, "Username", "Change username"),
                    const SizedBox(
                      height: 32,
                    ),
                    customTextField(bioEditingController, "Bio", "Change bio"),
                    const SizedBox(
                      height: 16,
                    ),
                    isUpdateLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                onPressed: () async {
                                  isUpdateLoading
                                      ? null
                                      : {
                                          setState(() {
                                            isUpdateLoading = true;
                                          }),
                                          await updateInfo(
                                              bioEditingController.text,
                                              nameEditingController.text),
                                          if (context.mounted)
                                            {
                                              setState(() {
                                                isUpdateLoading = false;
                                              }),
                                              getData(),
                                              Navigator.pop(context),
                                            }
                                        };
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.white12),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0))),
                                ),
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.white12),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0))),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> updateInfo(String bio, String name) async {
    String? photoUrl;
    if (_image != null) {
      photoUrl = await _storageController.uploadImageToStorage(
          'profilePics', _image!, false);
    }
    await _profileController.changeProfileInfo(
        userUid, bio, name, photoUrl ?? userData.photoUrl);
  }

  Widget customTextField(
      TextEditingController controller, String label, String hint) {
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)));
    return TextField(
      decoration: InputDecoration(
        filled: true,
        label: Text(label),
        hintText: hint,
        border: inputBorder,
        fillColor: Colors.white12,
        contentPadding: const EdgeInsets.all(10.0),
      ),
      autofocus: true,
      controller: controller,
    );
  }

  buildStartColumn(int num, String label) {
    return GestureDetector(
      onTap: () => {
        if (label != "Posts" && num > 0)
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => UserListScreen(
                      userId: currentUid,
                      title: label,
                      isFollowers: label == "Followers")))
              .then((value) async =>
                  value != null && value ? await getData() : null),
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

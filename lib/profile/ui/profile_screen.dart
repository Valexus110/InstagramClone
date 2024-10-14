import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart';
import 'package:instagram_example/chat/ui/chat_provider.dart';
import 'package:instagram_example/chat/ui/chat_screen.dart';
import 'package:instagram_example/common/common_controller.dart';
import 'package:instagram_example/posts/ui/saved_posts_screen.dart';
import 'package:instagram_example/profile/ui/profile_controller.dart';
import 'package:instagram_example/users_recommendation/ui/user_list_screen.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:instagram_example/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:instagram_example/models/user.dart' as model;
import 'package:shared_preferences/shared_preferences.dart';

import '../../authentication/ui/login_screen.dart';
import '../../common/widgets/follow_button.dart';
import '../../coordinate_layout/page_provider.dart';
import '../../main.dart';
import '../../models/chat.dart';
import '../../models/post.dart';
import '../../storage/storage_controller.dart';
import '../../utils/const_variables.dart';
import '../../utils/keystore.dart';
import '../utils.dart';

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
  bool isWriteMessageButtonLoading = false;
  final _commonController = CommonController();
  final _profileController = ProfileController();
  final _storageController = StorageController();
  AuthProvider authProvider = AuthProvider();
  late String userUid;
  late String currentUid;
  Uint8List? _image;
  StartPageEntries? selectedPage;
  final TextEditingController startingPageController = TextEditingController();
  int startPageNumber = 0;

  @override
  void initState() {
    super.initState();
    userUid = Provider.of<AuthProvider>(context, listen: false).getUserId();
    getSharedPreferences();
    getData();
  }

  getSharedPreferences({int pageNumber = 0, bool isSet = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (isSet) {
      await prefs.setInt(KeyStore.startPageNumber, pageNumber);
    }
    setState(() {
      startPageNumber = prefs.getInt(KeyStore.startPageNumber) ??
          KeyStore.startPageNumberDefault;
    });
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
                      pageProvider.pageSelection.jumpToPage(startPageNumber);
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
                    : Container(),
                IconButton(
                    onPressed: () => showDialog(
                        builder: (BuildContext context) => Padding(
                              padding: const EdgeInsets.only(
                                  top: 32, bottom: 32, left: 16.0, right: 16),
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                elevation: 16,
                                // backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(2),
                                title: Container(
                                  decoration: const BoxDecoration(),
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 32,
                                        ),
                                        Text(locale.changeHomePage),
                                        const SizedBox(
                                          height: 32,
                                        ),
                                        DropdownMenu<StartPageEntries>(
                                          initialSelection: StartPageEntries
                                              .values[startPageNumber],
                                          controller: startingPageController,
                                          label: Text(locale.startingPage),
                                          onSelected: (StartPageEntries? page) {
                                            setState(() {
                                              selectedPage = page;
                                            });
                                          },
                                          dropdownMenuEntries:
                                              StartPageEntries.values.map<
                                                      DropdownMenuEntry<
                                                          StartPageEntries>>(
                                                  (StartPageEntries page) {
                                            return DropdownMenuEntry<
                                                    StartPageEntries>(
                                                value: page,
                                                label: getEnumString(page),
                                                style: MenuItemButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white70));
                                          }).toList(),
                                        ),
                                        const SizedBox(
                                          height: 32,
                                        ),
                                        OutlinedButton(
                                          onPressed: () => changeStartingPage(),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.white12),
                                            shape: WidgetStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0))),
                                          ),
                                          child: Text(
                                            locale.accept,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        context: context),
                    icon: const Icon(Icons.settings))
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
                            GestureDetector(
                              onTap: () => showDialog(
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: const EdgeInsets.all(2),
                                        title: Container(
                                          decoration: const BoxDecoration(),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Image.network(
                                            userData.photoUrl,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                  context: context),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    NetworkImage(userData.photoUrl),
                                radius: 40,
                              ),
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
                                      buildStartColumn(postLen, locale.posts),
                                      buildStartColumn(
                                          followers, locale.followers),
                                      buildStartColumn(
                                          following, locale.following),
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
                                              text: locale.signOut,
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
                                                  text: locale.unfollow,
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
                                                  text: locale.follow,
                                                  isFollow: true,
                                                  isButtonLoading:
                                                      isFollowButtonLoading,
                                                  divider: 2,
                                                )
                                    ],
                                  ),
                                  if (userUid != currentUid)
                                    FollowButton(
                                      func: () async {
                                        setState(() {
                                          isWriteMessageButtonLoading = true;
                                        });
                                        await setChatInfo();
                                        if (!context.mounted) return;
                                        setState(() {
                                          isWriteMessageButtonLoading = false;
                                        });
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ChatScreen()));
                                      },
                                      text: locale.writeAMessage,
                                      isButtonLoading:
                                          isWriteMessageButtonLoading,
                                      isFollow: false,
                                      divider: 2,
                                    )
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
                                      child: Text(locale.editProfile))
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

  setChatInfo() async {
    var chatProvider = context.read<ChatProvider>();
    chatProvider.chatId = currentUid;
    var chats = await chatProvider.getChats(currentUid: userUid);
    try {
      Chat chat = chats.firstWhere((chat) => chat.uid == userData.uid,
          orElse: () => Chat(
              uid: currentUid,
              chatterUid: userData.uid,
              profilePic: userData.photoUrl,
              chatterName: userData.username));
      chatProvider.userData = chat;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void changeStartingPage() async {
    await getSharedPreferences(
        pageNumber: selectedPage?.number ?? 0, isSet: true);
    if (!mounted) return;
    Navigator.pop(context);
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
                    Text(
                      locale.editProfile,
                      style: const TextStyle(fontSize: 24),
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
                      child: Text(locale.changeProfilePhoto),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    customTextField(nameEditingController, locale.username,
                        locale.changeUsername),
                    const SizedBox(
                      height: 32,
                    ),
                    customTextField(
                        bioEditingController, locale.bio, locale.changeBio),
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
                                child: Text(
                                  locale.submit,
                                  style: const TextStyle(color: Colors.white),
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
                                child: Text(
                                  locale.cancel,
                                  style: const TextStyle(color: Colors.white),
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
          profilePics, _image!, false);
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
        if (label != locale.posts && num > 0)
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => UserListScreen(
                      userId: currentUid,
                      title: label,
                      isFollowers: label == locale.followers)))
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

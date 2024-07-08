import 'package:flutter/material.dart';
import 'package:instagram_example/profile/profile_screen.dart';
import 'package:instagram_example/search/ui/search_controller.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:instagram_example/models/user.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final SearchUsersController _searchController = SearchUsersController();
  String currentName = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // getUsers() async {
  //   List<QueryDocumentSnapshot<Map<String, dynamic>>> actualUsers = [];
  //   if (currName.isEmpty) return;
  //   var users = await firestore.collection('users').get();
  //   for (var user in users.docs) {
  //     if (user.id == userId) continue;
  //     if (user
  //         .data()['username']
  //         .toString()
  //         .toLowerCase()
  //         .contains(currName.toLowerCase())) {
  //       actualUsers.add(user);
  //     }
  //   }
  //   return actualUsers;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
                icon: Icon(Icons.search),
                hintText: 'type a username',
                labelText: "Search for a user",
                labelStyle: TextStyle(fontSize: 20)),
            onChanged: (str) {
              setState(() {
                currentName = str;
              });
            },
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: Colors.grey,
                height: 4.0,
              )),
        ),
        body: FutureBuilder(
          future: _searchController.searchRepository.getUsers(currentName),
          builder: (context, snapshot) {
            if (currentName.isEmpty) {
              return Container();
            } else if (!snapshot.hasData && currentName.isNotEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                itemCount: (snapshot.data! as dynamic).length,
                itemBuilder: (context, index) {
                  var user = User.fromJson((snapshot.data! as dynamic)[index]);
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                              uid: user.uid,
                            ))),
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                        user.photoUrl,
                      )),
                      title: Text(user.username),
                    ),
                  );
                });
          },
        ));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/screens/profile_screen.dart';
import 'package:instagram_example/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String currName = "";
  String userId = "";

  @override
  void initState() {
    userId = auth.currentUser!.uid;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  getUsers() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> actualUsers = [];
    if (currName.isEmpty) return;
    var users = await firestore.collection('users').get();
    for (var user in users.docs) {
      if (user.id == userId) continue;
      if (user
          .data()['username']
          .toString()
          .toLowerCase()
          .contains(currName.toLowerCase())) {
        actualUsers.add(user);
      }
    }
    return actualUsers;
  }

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
                currName = str;
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
          future: getUsers(),
          builder: (context, snapshot) {
            if (currName.isEmpty) {
              return Container();
            } else if (!snapshot.hasData && currName.isNotEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                itemCount: (snapshot.data! as dynamic).length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                            uid: (snapshot.data! as dynamic)[index]['uid']))),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            (snapshot.data! as dynamic)[index]['photoUrl']),
                      ),
                      title:
                          Text((snapshot.data! as dynamic)[index]['username']),
                    ),
                  );
                });
          },
        ));
  }
}

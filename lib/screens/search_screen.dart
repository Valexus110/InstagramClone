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
  bool isShowUsers = false;
  var name = "";

  @override
  void initState() {
    getUserName();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getUserName() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User currentUser = _auth.currentUser!;
    var snap = await _firestore.collection('users').doc(currentUser.uid).get();
    name = snap.data()!['username'];
    print(name);
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
            onChanged: (_) {
              setState(() {
                isShowUsers = false;
              });
            },
            onFieldSubmitted: (String currName) {
              print(name);
              print(currName);
              name = name.toLowerCase().trim();
              currName = currName.toLowerCase().trim();
              setState(() {
                if (currName != name) {
                  isShowUsers = true;
                }
              });
            },
          ),
          bottom: PreferredSize(
              child: Container(
                color: Colors.grey,
                height: 4.0,
              ),
              preferredSize: const Size.fromHeight(4.0)),
        ),
        body: isShowUsers
            ? FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where(
                      "username",
                      isEqualTo: _controller.text,
                    )
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                      uid: (snapshot.data! as dynamic)
                                          .docs[index]['uid'],
                                      search: true))),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  (snapshot.data! as dynamic).docs[index]
                                      ['photoUrl']),
                            ),
                            title: Text((snapshot.data! as dynamic).docs[index]
                                ['username']),
                          ),
                        );
                      });
                },
              )
            : Container());
  }
}

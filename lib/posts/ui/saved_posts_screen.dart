import 'package:flutter/material.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart';
import 'package:instagram_example/models/post.dart';
import 'package:instagram_example/posts/ui/posts_controller.dart';
import 'package:instagram_example/utils/global_variables.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/post_card.dart';
import '../../main.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  var saved = [];
  final postsController = PostsController();
  late final AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    postsController.getSavedPosts();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
           locale.favouritePosts,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: StreamBuilder(
            stream: postsController.getListOfPosts(authProvider.getUserId()),
            builder: (context, AsyncSnapshot<List<Post>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data != null ? snapshot.data!.length : 0,
                  itemBuilder: (context, index) => Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: width > webScreenSize ? width * 0.3 : 0,
                          vertical: width > webScreenSize ? 15 : 0,
                        ),
                        child: PostCard(
                          snap: snapshot.data![index],
                          //Post.fromJson(snapshot.data![index]),
                          savedScreen: true,
                        ),
                      ));
            }));
  }
}

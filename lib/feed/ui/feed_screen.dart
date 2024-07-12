import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart';
import 'package:instagram_example/feed/ui/feed_controller.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:instagram_example/utils/global_variables.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/post_card.dart';
import '../../models/post.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Stream<List<Post>>? stream;
  final feedController = FeedController();

  @override
  void initState() {
    super.initState();
    stream = feedController.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var user = Provider.of<AuthProvider>(context).getUser;
    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: SvgPicture.asset(
                'assets/ic_instagram.svg',
                colorFilter:
                    const ColorFilter.mode(primaryColor, BlendMode.srcIn),
                height: 32,
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.messenger_outline),
                ),
              ],
            ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: stream,
              builder: (context, AsyncSnapshot<List<Post>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    setState(() {
                      stream = feedController.getPosts();
                    });
                    await Future.delayed(const Duration(milliseconds: 300));
                  },
                  child: ListView.builder(
                      itemCount:
                          snapshot.data != null ? snapshot.data!.length : 0,
                      itemBuilder: (context, index) => Container(
                        decoration: const BoxDecoration(color: Colors.black),
                            margin: EdgeInsets.symmetric(
                              horizontal:
                                  width > webScreenSize ? width * 0.3 : 16,
                              vertical: width > webScreenSize ? 15 : 8,
                            ),
                            child: PostCard(
                              snap: snapshot.data![index],
                            ),
                          )),
                );
              }),
    );
  }
}

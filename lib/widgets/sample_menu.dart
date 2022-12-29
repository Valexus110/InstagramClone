import 'package:flutter/material.dart';
import 'package:instagram_example/screens/saved_posts_screen.dart';
import 'package:instagram_example/utils/menu_options.dart';

class SampleMenu extends StatelessWidget {
  const SampleMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProfileMenuOptions>(
      onSelected: (ProfileMenuOptions value) {
        switch (value) {
          case ProfileMenuOptions.saved:
            openSavedPosts(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuItem<ProfileMenuOptions>>[
        const PopupMenuItem<ProfileMenuOptions>(
          value: ProfileMenuOptions.saved,
          child: Text('Saved'),
        ),
      ],
    );
  }

  void openSavedPosts(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SavedPostsScreen()));
  }
}

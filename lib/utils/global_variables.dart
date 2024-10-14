import 'package:flutter/material.dart';
import 'package:instagram_example/users_recommendation/ui/user_list_screen.dart';
import 'package:instagram_example/feed/ui/feed_screen.dart';
import 'package:instagram_example/profile/ui/profile_screen.dart';
import 'package:instagram_example/search/ui/search_screen.dart';

import '../main.dart';
import '../posts/ui/add_post_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  UserListScreen(
    title: locale.usersYouMightKnow,
  ),
  const ProfileScreen(),
];

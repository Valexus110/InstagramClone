import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/add_post/add_post_screen.dart';
import 'package:instagram_example/profile/user_list_screen.dart';
import 'package:instagram_example/feed/ui/feed_screen.dart';
import 'package:instagram_example/profile/profile_screen.dart';
import 'package:instagram_example/search/ui/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const UserListScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];

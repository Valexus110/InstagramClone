import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/screens/add_post_screen.dart';
import 'package:instagram_example/screens/user_list_screen.dart';
import 'package:instagram_example/screens/feed_screen.dart';
import 'package:instagram_example/screens/profile_screen.dart';
import 'package:instagram_example/screens/search_screen.dart';

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

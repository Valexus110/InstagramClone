import 'package:flutter/material.dart';
import 'package:instagram_example/coordinate_layout/web_screen_layout.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart';
import 'package:instagram_example/utils/global_variables.dart';
import 'package:provider/provider.dart';

import 'mobile_screen_layout.dart';

class CoordinateLayout extends StatefulWidget {
  const CoordinateLayout(
      {Key? key})
      : super(key: key);

  @override
  State<CoordinateLayout> createState() => _CoordinateLayoutState();
}

class _CoordinateLayoutState extends State<CoordinateLayout> {
  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    AuthProvider userProvider =
        Provider.of<AuthProvider>(context, listen: false);
    await userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > webScreenSize) {
          const WebScreenLayout();
        }
        return const MobileScreenLayout();
      },
    );
  }
}

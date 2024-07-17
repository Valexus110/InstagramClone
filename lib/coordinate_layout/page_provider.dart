import 'package:flutter/material.dart';

class PageProvider extends ChangeNotifier{
  PageController _pageSelection= PageController(initialPage: 0);

  PageController get pageSelection{
    return _pageSelection;
  }

  set pageSelection(PageController i){
    _pageSelection=i;
    notifyListeners();
  }
}
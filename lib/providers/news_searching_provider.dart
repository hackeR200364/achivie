import 'package:flutter/cupertino.dart';

class NewsSearchingProvider extends ChangeNotifier {
  String query = "";
  void queryFunc(String userQuery) {
    query = userQuery;
    notifyListeners();
  }

  int searchTextIndex = 0;
  void searchTextIndexFunc(int index) {
    searchTextIndex = index;
    notifyListeners();
  }
}

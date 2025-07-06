import 'package:flutter/cupertino.dart';

class NodeComponentIndexProvider with ChangeNotifier{
  int _index;
  NodeComponentIndexProvider(this._index );
  int get index => _index;
  set index(int newIndex) {
    if (newIndex != _index) {
      _index = newIndex;
      notifyListeners();
    }
  }
}
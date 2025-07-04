// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/entity/data/entity.dart';


abstract class Component with ChangeNotifier {
  bool isActive;

  Component({this.isActive = true});


  Component copy();

   Map<String, dynamic> toJson();


  void update(Duration dt, {required Entity activeEntity});

  void reset();

  void toggleComponent() {
    isActive = !isActive;
    notifyListeners();
  }
}
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

abstract class Component with ChangeNotifier{

  bool isActive;
  Component(
    {this.isActive = true}
  );
  void update(Duration dt,{required Entity activeEntity,required EntityManager entityManager});
  void toggleComponent(){
    isActive = !isActive;
    notifyListeners();
  }
}

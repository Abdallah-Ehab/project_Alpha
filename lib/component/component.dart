// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/block_feature/data/block_component.dart';
import 'package:scratch_clone/entity/data/entity.dart';


abstract class Component with ChangeNotifier {
  bool isActive;

  Component({this.isActive = true});


  Component copy();


  factory Component.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'Animation':
        return AnimationControllerComponent.fromJson(json);
      case 'Block':
        return BlockComponent.fromJson(json);
      default:
        throw Exception('Unknown entity type');
    }
  }

  Map<String, dynamic> toJson();

  void update(Duration dt, {required Entity activeEntity});

  void reset();

  void toggleComponent() {
    isActive = !isActive;
    notifyListeners();
  }
}
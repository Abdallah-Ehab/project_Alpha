import 'package:flutter/material.dart';

class ColliderWidget extends StatelessWidget {
  final double width;
  final double height;
  const ColliderWidget({super.key,required this.width,required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.red,width: 2, style: BorderStyle.solid),
      ),
      
      );
  }
}
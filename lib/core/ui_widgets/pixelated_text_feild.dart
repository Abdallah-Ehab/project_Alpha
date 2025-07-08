import 'package:flutter/material.dart';

class PixelatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final Color borderColor;
  final Color? labelColor;
  final String? label;

   const PixelatedTextField({

    super.key,
    this.label,
    this.labelColor,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.keyboardType = const TextInputType.numberWithOptions(),Color? borderColor  // default to numbers
  }) :borderColor=borderColor ?? Colors.black;

 

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (label != null) Expanded(child: Text(label!,style: TextStyle(color: labelColor),)),
        Expanded(
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'PressStart2P',
          ),
          maxLength: 5,
          controller: controller,
          keyboardType: keyboardType,  // uses passed in type or falls back to numeric
          cursorColor: Colors.white,
          cursorWidth: 4,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: const Color(0xFF222222),
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontFamily: 'PressStart2P',
            ),
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:  BorderSide(
                color: borderColor,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ),
 ]   );
  }
}















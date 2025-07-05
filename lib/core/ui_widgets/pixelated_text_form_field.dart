
import 'package:flutter/material.dart';

class PixelatedTextFormField extends StatelessWidget {
  final String? initialValue;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final Color borderColor;
  final Key? fieldKey;
  final String label ;
  const PixelatedTextFormField({
    super.key,
    this.initialValue,
    required this.hintText,
    required this.label,
    this.onChanged,
    this.keyboardType = const TextInputType.numberWithOptions(),
    Color? borderColor,
    this.fieldKey,
  }) : borderColor = borderColor ?? Colors.black;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'PressStart2P',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          
          child: TextFormField(
            
            key: fieldKey,
            initialValue: initialValue,
            onChanged: onChanged,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'PressStart2P',
            ),
            maxLength: 5,
            keyboardType: keyboardType,
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
                borderSide: BorderSide(
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
      ],
    );
  }
}
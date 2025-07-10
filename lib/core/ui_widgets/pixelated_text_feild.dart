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
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.keyboardType = const TextInputType.numberWithOptions(),
    this.label,
    this.labelColor,
    Color? borderColor,
  }) : borderColor = borderColor ?? Colors.black;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (label != null)
          Expanded(
            child: Text(
              label!,
              style: TextStyle(color: labelColor),
            ),
          ),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLength: 5,
            cursorColor: Colors.white,
            cursorWidth: 4,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'PressStart2P',
            ),
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
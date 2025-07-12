import 'package:flutter/material.dart';

class SoundControllerWidget extends StatefulWidget {
  final List<String> options;
  final bool initiallyChecked;
  final String? initiallySelection;
  final ValueChanged<bool> onToggleChecked;
  final ValueChanged<String> onTrackChanged;
  final VoidCallback onOpenEditor;

  const SoundControllerWidget({
    super.key,
    required this.options,
    required this.initiallyChecked,
    required this.initiallySelection,
    required this.onToggleChecked,
    required this.onTrackChanged,
    required this.onOpenEditor,
  });

  @override
  _SoundControllerWidgetState createState() =>
      _SoundControllerWidgetState();
}

class _SoundControllerWidgetState extends State<SoundControllerWidget>
    with TickerProviderStateMixin {
  late bool _isChecked;
  late String? _selectedOption;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initiallyChecked;
    _selectedOption = widget.initiallySelection;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Card(
          color: const Color(0xFF222222),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: checkbox, label, expand arrow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (bool? value) {
                        final v = value ?? false;
                        setState(() => _isChecked = v);
                        widget.onToggleChecked(v);
                      },
                      checkColor: Colors.white,
                      fillColor:
                      WidgetStateProperty.resolveWith<Color>((states) {
                        return Colors.transparent;
                      }),
                      side: const BorderSide(color: Colors.white, width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Sound Component",
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_outlined
                            : Icons.keyboard_arrow_down_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.open_in_full,
                        color: Colors.white,
                      ),
                      onPressed: widget.onOpenEditor,
                      tooltip: 'Open Full Editor',
                    ),
                  ],
                ),

                // Expanded list of radio options
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      children: widget.options.map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: RadioListTile<String>(
                            activeColor: Colors.white,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              option,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'PressStart2P',
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            value: option,
                            groupValue: _selectedOption,
                            onChanged: (String? value) {
                              if (value == null) return;
                              setState(() => _selectedOption = value);
                              widget.onTrackChanged(value);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
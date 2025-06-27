import 'dart:ui';

extension OffsetJson on Offset {
  Map<String, dynamic> toJson() => {'dx': dx, 'dy': dy};

  static Offset fromJson(Map<String, dynamic> json) => Offset(
        (json['dx'] as num).toDouble(),
        (json['dy'] as num).toDouble(),
      );
}

extension ColorJson on Color {
  int toJson() => toARGB32();

  static Color fromJson(int colorValue) => Color(colorValue);
}

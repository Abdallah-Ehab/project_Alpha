enum ButtonType {
  tap,
  hold,
  longPress,
}

extension ButtonTypeLabel on ButtonType {
  String get label {
    switch (this) {
      case ButtonType.tap: return "Tap Button";
      case ButtonType.hold: return "Hold Button";
      case ButtonType.longPress: return "Long Press Button";
    }
  }
}

dynamic parseStringValue(String rawValue) {
  dynamic value;
  if (int.tryParse(rawValue) != null) {
    value = int.parse(rawValue);
  } else if (double.tryParse(rawValue) != null) {
    value = double.parse(rawValue);
  } else if (rawValue.toLowerCase() == 'true' ||
      rawValue.toLowerCase() == 'false') {
    value = rawValue.toLowerCase() == 'true';
  } else {
    value = rawValue;
  }
  return value;
}

bool emailValidation(String text) {
  return RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(text);
}

bool passFormatValidation(String text) {
  return RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{4,}$').hasMatch(text);
}

bool passLengthValidation(String text) {
  return text.length > 7;
}

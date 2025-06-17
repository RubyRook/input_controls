enum LocaleName {en, km;
  static LocaleName fromString(String value){
    if (value == km.name) return km;
    return en;
  }
}

class InputConfig {
  InputConfig._();
  static final instance = InputConfig._();

  LocaleName locale = LocaleName.en;

}
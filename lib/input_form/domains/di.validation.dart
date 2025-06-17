enum Locale {en, km;
 static Locale fromString(String value){
   if (value == km.name) return km;
   return en;
 }
}

/// Each element has it own validate message
enum Required {text, select;

  String message (String fieldLabel) {
    final languages = ValidationMsg.instance;

    if (this == select) return languages.selectRequired(fieldLabel);
    return languages.required(fieldLabel);
  }
}

class Validation {
  Validation._();
  static final instance = Validation._();
  
  final languages = ValidationMsg.instance;

  /// Return null if value is valid
  String? validator(String fieldLabel, String? value, {
    required ValidatorRules rules,
  })
  {
    if (rules.require case final req?) return require(fieldLabel, value, req);
    
    if (value != null) {
      value = value.trim();

      // Check string length
      if (rules.min_length case final length?) {
        return min_length(fieldLabel, value, length);
      }

      if (rules.max_length case final lenght?) {
        return max_length(fieldLabel, value, lenght);
      }
      
      if (rules.exact_length case final lenght?) {
        return exact_length(fieldLabel, value, lenght);
      }

      // Check num
      if (rules.less_than case final lessThan?) {
        return less_than(fieldLabel, value, lessThan);
      }

      if (rules.less_than_equal_to case final lessThanEqualTo?) {
        return less_than_equal_to(fieldLabel, value, lessThanEqualTo);
      }

      if (rules.greater_than case final greaterThan?) {
        return greater_than(fieldLabel, value, greaterThan);
      }

      if (rules.greater_than_equal_to case final greaterThanEqualTo?) {
        return greater_than_equal_to(fieldLabel, value, greaterThanEqualTo);
      }

      // Check format
      if (rules.numeric == true) return isNumeric(fieldLabel, value);

      if (rules.phone_format == true) return phone_format(fieldLabel, value);

      if (rules.phone_all_format == true) return phone_all_format(fieldLabel, value);

      if (rules.email_format == true) return email_format(fieldLabel, value);

      if (rules.birth_year_format case final birthYearFormat?) return birth_year_format(fieldLabel, value, birthYearFormat);
    }
    
    return null;
  }

  String? require (String fieldLabel, String? value, Required req) {
    if (value == null || value.isEmpty) {
      return req.message(fieldLabel);
    }
    
    return null;
  }

  String? min_length (String fieldLabel, String value, int length) {
    if (value.isNotEmpty && value.length < length) {
      return languages.minLength(fieldLabel, length);
    }
    return null;
  }

  String? max_length (String fieldLabel, String value, int length) {
    if (value.isNotEmpty && value.length > length) {
      return languages.maxLength(fieldLabel, length);
    }
    
    return null;
  }

  String? exact_length (String fieldLabel, String value, int length) {
    if (value.isNotEmpty && value.length != length) {
      return languages.exactLength(fieldLabel, length);
    }

    return null;
  }

  String? less_than (String fieldLabel, String value, double lessThan) {
    if (double.tryParse(value) case final val? when val >= lessThan) {
      return languages.lessThan(fieldLabel, lessThan);
    }
    
    return null;
  }

  String? less_than_equal_to (String fieldLabel, String value, double lessThanEqualTo) {
    if (double.tryParse(value) case final val? when val > lessThanEqualTo) {
      return languages.lessThanEqualTo(fieldLabel, lessThanEqualTo);
    }

    return null;
  }

  String? greater_than (String fieldLabel, String value, double greaterThan) {
    if (double.tryParse(value) case final val? when val <= greaterThan) {
      return languages.greaterThan(fieldLabel, greaterThan);
    }
    
    return null;
  }

  String? greater_than_equal_to (String fieldLabel, String value, double greaterThanEqualTo) {
    if (double.tryParse(value) case final val? when val < greaterThanEqualTo) {
      return languages.greaterThanEqualTo(fieldLabel, greaterThanEqualTo);
    }
    
    return null;
  }

  String? isNumeric (String fieldLabel, String value) {
    if (value.isNotEmpty) {
      const pattern = r'^([0-9])';
      final regex = RegExp(pattern);
      
      if (!regex.hasMatch(value)) {
        return languages.numeric(fieldLabel);
      }
    }
    
    return null;
  }

  String? phone_format (String fieldLabel, String value) {
    if (value.isNotEmpty) {
      const pattern = r'^0[1-9]{1}[0-9]{7,8}$';
      final regex = RegExp(pattern.toString());
      
      if (!regex.hasMatch(value) || value.length > 15) {
        return languages.invalid(fieldLabel);
      }
    }
    
    return null;
  }

  String? phone_all_format (String fieldLabel, String value) {
    if (value.isNotEmpty) {
      const pattern = r'^(0[1-9]{1}[0-9]{1} [0-9]{2} [0-9]{2} [0-9]{2,3})|(0[1-9]{1}[0-9]{1}[\ |\-][0-9]{1,8}[\ |\-][0-9]{1,8})|([\+]855[\ |][1-9]{8,10})|(([\+]855|0)[1-9]{1}[0-9]{1}([0-9]|)(\ |)[0-9]{6,7})$';
      final regex = RegExp(pattern.toString());
      if (!regex.hasMatch(value) || value.length > 15) {
        return languages.invalid(fieldLabel);
      }
    }
    
    return null;
  }

  String? email_format (String fieldLabel, String value) {
    const pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final regex = RegExp(pattern.toString());
    
    if (!regex.hasMatch(value)) {
      return languages.invalid(fieldLabel);
    }
    
    return null;
  }

  String? birth_year_format (String fieldLabel, String value, int providedYear) {
    int? birthYear = int.tryParse(value);

    if (birthYear != null && birthYear >= providedYear){
      return languages.invalidBirthYear(fieldLabel);
    }
    
    return null;
  }
}

class ValidationMsg {
  Locale locale = Locale.en;

  ValidationMsg._();
  static final instance = ValidationMsg._();

  String maxLength (String label, Object param) => get({
    Locale.en:'The “$label” field cannot exceed $param characters in length.',
    Locale.km:'“$label” មិនអាចលើសពី $param តួអក្សរដែលមានប្រវែង។',
  });

  String minLength (String label, Object param) => get({
    Locale.en:'The “$label” field must be at least $param characters in length.',
    Locale.km:'“$label” ត្រូវតែមានយ៉ាងហោចណាស់ $param តួអក្សរ។',
  });

  String invalid(String label) => get({Locale.en:"The “$label” is invalid.",Locale.km:"“$label” មិនត្រឹមត្រូវទេ។"});
  String required(String label) => get({Locale.en:"Please enter the “$label”.",Locale.km:"សូមបញ្ចូល “$label”។"});
  String selectRequired(String label) => get({Locale.en:"Please select any “$label”.",Locale.km:"សូមជ្រើសរើស “$label” ណាមួយ។"});
  String numeric(String label) => get({Locale.en:"The “$label” field must contain only numbers.", Locale.km:"“$label” ត្រូវមានតែលេខប៉ុណ្ណោះ។"});
  String invalidBirthYear(String label) => get({Locale.en:"The “$label” must be smaller than current year.",Locale.km:"“$label” ត្រូវតែតូចជាងឆ្នាំបច្ចុប្បន្ន។"});

  String exactLength(String label, Object param) => get({Locale.en:"The “$label” field must be equal $param characters in length.",Locale.km:"“$label” ត្រូវតែស្មើ $param តួអក្សរដែលមានប្រវែង។"});
  String lessThan(String label, Object param) => get({Locale.en:"The “$label” field must be less than $param.",Locale.km:"“$label” ត្រូវតែតិចជាង $param។"});
  String lessThanEqualTo(String label, Object param) => get({Locale.en:"The “$label” field must be less than or equal $param.",Locale.km:"“$label” ត្រូវតែតិចជាង ឬស្មើ $param។"});
  String greaterThan(String label, Object param) => get({Locale.en:"The “$label” field must be greater than $param.",Locale.km:"“$label” ត្រូវតែធំជាង $param។"});
  String greaterThanEqualTo(String label, Object param) => get({Locale.en:"The “$label” field greater than or equal $param.",Locale.km:"“$label” ត្រូវតែធំជាង ឬស្មើ $param។"});

  String get priceGreaterThanEqualTo => get({Locale.en:"Please enter the valid price.",Locale.km:"សូមបញ្ចូលតម្លៃអោយបានត្រឹមត្រូវ។"});

  String get(Map<Locale, String> languages){
    if (languages[locale] case final result?) return result;
    return languages.values.first;
  }
}

class ValidatorRules {
  final bool? email_format;
  final bool? numeric;
  final bool? phone_all_format;
  final bool? phone_format;
  final Required? require;

  final int? exact_length;
  final int? max_length;
  final int? min_length;
  final int? birth_year_format;

  final double? greater_than;
  final double? greater_than_equal_to;
  final double? less_than;
  final double? less_than_equal_to;

  ValidatorRules({
    this.email_format,
    this.numeric,
    this.phone_all_format,
    this.phone_format,
    this.require,
    this.exact_length,
    this.max_length,
    this.min_length,
    this.birth_year_format,
    this.greater_than,
    this.greater_than_equal_to,
    this.less_than,
    this.less_than_equal_to,
  });
}



import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:input_controls/input_form/domains/di.input_form.dart';

export 'package:input_controls/input_form/domains/di.input_form.dart';
export 'package:input_controls/input_form/domains/di.validation.dart';
export 'package:input_controls/input_form/presentations/custom_input.dart';
export 'package:input_controls/input_form/presentations/default_style.dart';

final class InputGroup {
  InputGroup(Map<String, InputType> inputs){
    _inputs = inputs;
  }

  late Map<String, InputType> _inputs;
  Map<String, InputType> get inputs => _inputs;

  /// Get form data.
  Map<String, String> get data {
    return inputs.map((key, value) {
      String result = '';

      if (value case InputTypePick input) {
        result = _convertValue(input.active?.value);
      }
      else if (value case InputTypeSelect input) {
        result = _convertValue(input.active?.value);
      }
      else if (value case InputTypeSwitch input) {
        result = _convertValue(input.active.value);
      }
      else if (value case InputTypeText input) {
        result = input.controller.text;
      }

      return MapEntry(key, result);
    },);
  }

  String _convertValue(Object? data) {
    if (data is bool || data is int || data is double) {
      return data.toString();
    }
    else if (data is Map || data is List) {
      try {
        return jsonEncode(data);
      }
      catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);
      }
    }
    return '';
  }
}
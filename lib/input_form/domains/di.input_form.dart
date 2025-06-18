import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:input_controls/input_form/domains/di.validation.dart';
import 'package:input_controls/input_form/presentations/default_style.dart';

Widget switchObscureTextWidget(void Function() rebuild, InputTypeText instance) {
  return IconButton(
    autofocus: false,
    icon: FaIcon(instance.obscureText == true
        ? FontAwesomeIcons.eye
        : FontAwesomeIcons.eyeSlash,
      color: Colors.grey,
      size: 18,
    ),
    onPressed: () async {
      instance.obscureText = !instance.obscureText;
      rebuild();
    },
  );
}

/// Ignore focus when tap on text field
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

final class InputData<T> {
  final String label;
  final T value;

  InputData(this.label, this.value);

  InputData<T> get clone => InputData<T>(label, value);
}

sealed class InputType<
P extends InputTypePick,
S extends InputTypeSelect,
S_ extends InputTypeSwitch,
T extends InputTypeText
> {
  final String label;
  final ValidatorRules? rules;
  InputType({
    required this.label,
    this.rules,
  });

  final controller = TextEditingController();
  final validate = ValueNotifier<String?>(null);
  String? _serverValidate;

  InputDecoration get decoration => decorationTextForm.copyWith(
    errorStyle: const TextStyle(fontSize: 0, height: -.1),
    labelText: label,
  );

  void clearError () {
    validate.value = null;
    _serverValidate = null;
  }

  void serverError (String value) {
    _serverValidate = value;
    validate.value = value;
  }

  void dispose() {
    controller.dispose();
    validate.dispose();
  }

  void onChanged (String? value) {
    if (_serverValidate != null) _serverValidate = null;
  }

  String? validator (String? value) {
    // Prevent form clear message when form validate
    if (_serverValidate != null) return _serverValidate;
    // Perform validate value
    return _validator(value);
  }

  String? _validator (String? value) {
    final val = Validation.instance.validator(label, value, rules: rules ?? ValidatorRules());

    if (val case String message? when message.isNotEmpty) {
      Future.delayed(Duration.zero, ()=> validate.value = message,);
      return '';
    }

    Future.delayed(Duration.zero, ()=> validate.value = null,);
    return null;
  }
}

/// This object specific on type Radio. Or, switches with element more than 2
final class InputTypePick<T> extends InputType {
  final List<InputData<T>> element;
  /// For show button any
  final bool any;

  InputTypePick({
    required super.label,
    required this.element,
    this.any = false,
    this.active,
    super.rules,
  });

  InputData<T>? active;
}

final class InputTypeSelect<T> extends InputType {
  late final Future<InputData<T>?> Function(BuildContext context) onSelect;

  InputTypeSelect({
    required super.label,
    required Future<InputData<T>?> Function(InputData<T>? active, BuildContext context) onSelect,
    this.active,
    super.rules,
  }){
    this.onSelect = (context) async {
      final result = await onSelect(active, context);
      if (result != null) {
        active = result;
        controller.text = result.label;
      }
      return result;
    };
  }

  InputData<T>? active;
  final focusNode = AlwaysDisabledFocusNode();
}

final class InputTypeSwitch<T> extends InputType {
  final InputData<T> value1;
  final InputData<T> value2;

  InputTypeSwitch({
    required super.label,
    required this.value1,
    required this.value2,
    required this.active,
    super.rules,
  });

  InputData<T> active;
  List<InputData<T>> get element => [value1, value2];
}

final class InputTypeText extends InputType {
  final int minLines;
  /// Other FocusNode that keyboard onEditingComplete should focus
  final FocusNode? next;
  /// void Function() rebuild is prefer to setState or any notifier method that can rebuild widget
  final Widget Function(void Function() rebuild, InputTypeText instance)? suffixIcon;

  late final focusNode = FocusNode();

  bool obscureText;

  InputTypeText({
    required super.label,
    this.minLines = 1,
    this.next,
    this.obscureText = false,
    this.suffixIcon,
    super.rules,
  });

  @override
  void dispose(){
    super.dispose();
    focusNode.dispose();
  }

}

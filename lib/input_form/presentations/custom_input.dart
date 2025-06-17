import 'default_style.dart';
import '../domains/di.input_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

Color _backgroundColor(BuildContext context)=> Theme.of(context).brightness == Brightness.light
    ? Colors.white
    : const Color(0xff3A3A3C);

Color _label(BuildContext context)=> Theme.of(context).brightness == Brightness.light
    ? Colors.black
    : Colors.white;

Color _softLabel(BuildContext context)=> Theme.of(context).brightness == Brightness.light
    ? Colors.black54
    : Colors.white;

class InputField<T> extends StatelessWidget {
  const InputField({super.key, required this.input});
  final InputType input;

  @override
  Widget build(BuildContext context) {
    if (input case InputTypePick<T> input) {
      return InputRadioField(input: input);
    }
    else if (input case InputTypeSelect<T> input) {
      return InputSelectField(input: input);
    }
    else if (input case InputTypeSwitch<T> input) {
      return InputSwitchTwoElementField(input: input);
    }
    else if (input case InputTypeText input) {
      return InputTextFieldState(input: input);
    }

    return const SizedBox();
  }
}

class InputRadioField<T> extends StatelessWidget {
  final InputTypePick<T> input;
  final double titleSize;

  const InputRadioField({
    super.key,
    required this.input,
    this.titleSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = 15.0;
    final length = input.any ? input.element.length+1:input.element.length;
    final items = length == 2 ? 2.0:3.0;

    return LayoutBuilder(builder: (context, constraints) {
      final width = calcSpaceBetween(width: constraints.maxWidth, spacing: spacing, items: items);

      return ValueListenableBuilder(
        valueListenable: input.controller,
        builder: (_, _, _) {
          List<Widget> children = List.generate(input.element.length, (index) {
            final data = input.element[index];
            final isActive = input.active?.value == data.value;

            return TextButton(
              onPressed: () async {
                input.active = data.clone;
                input.controller.text = data.label;
              },
              style: style(isActive, width, context),
              child: Text(
                data.label,
                style: TextStyle(
                  color: _label(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          });

          if (input.any) {
            final isActive = input.active == null;
            children.insert(0, TextButton(
              onPressed: () async {
                input.active = null;
                input.controller.text = '';
              },
              style: style(isActive, width, context),
              child: Text(
                'Any',
                style: TextStyle(
                  color: _label(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ));
          }

          return Stack(
            children: [
              // Hidden form
              Positioned(
                top: 0, bottom: 0, left: 0, right: 0,
                child: Opacity(
                  opacity: 0,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: input.controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: input.onChanged,
                    readOnly: true,
                    validator: input.validator,
                  ),
                ),
              ),
              // Main
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    input.label,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w500,
                      // color: errorColor ?? labelColor,
                    ),
                  ),
                  const Gap(10),
                  // Radio
                  Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: children,
                  ),
                  // Error Message
                  ValueListenableBuilder(
                    valueListenable: input.validate,
                    builder: (_, value, _) {
                      if (value != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: InputErrorMessage(text: value),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
  }

  ButtonStyle style(bool isActive, double width, BuildContext context) {
    return TextButton.styleFrom(
      alignment: Alignment.center,
      maximumSize: Size(width, 48),
      minimumSize: Size(width, 48),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,

      backgroundColor: isActive
          ? CupertinoColors.activeBlue.withValues(alpha:0.1)
          : _backgroundColor(context),
      side: isActive
          ? defaultBorder.borderSide.copyWith(color: CupertinoColors.activeBlue)
          : defaultBorder.borderSide,
    );
  }

  double calcSpaceBetween({
    required double width,
    required double spacing,
    required double items,
  })
  {
    double childWidth = width;
    double multiplier = items-1;

    if (items > 1) {
      childWidth = width-(spacing*multiplier);
      childWidth = childWidth / items;

      // Progress to remove smaller to ones
      // if you don't understand. Go to learn basic mathematics again
      List<String> split = childWidth.toString().split(".");
      if(split.length == 2 && split.last.length > 1) {
        double wholeNumber = double.parse(split.first);
        // Remove smaller to ones
        // Exp: remove 0.666666666 until 0.6
        double decimal = double.parse(split.last[0])*10/100;
        childWidth = wholeNumber+decimal;
      }
    }

    return childWidth;
  }
}

class InputSelectField<T> extends StatelessWidget {
  final InputTypeSelect<T> input;

  const InputSelectField({
    super.key,
    required this.input,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: input.controller,
      builder: (_, _, _) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: input.controller,
            decoration: input.decoration.copyWith(
              fillColor: _backgroundColor(context),
            ),
            focusNode: input.focusNode,
            onTap: () => input.onSelect(context),
            onChanged: input.onChanged,
            readOnly: true,
            validator: input.validator,
          ),
          ValueListenableBuilder(
            valueListenable: input.validate,
            builder: (_, value, _) {
              if (value != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: InputErrorMessage(text: value),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}

class InputSwitchTwoElementField<T> extends StatelessWidget {
  final InputTypeSwitch<T> input;
  final double titleSize;

  const InputSwitchTwoElementField({
    super.key,
    required this.input,
    this.titleSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: input.controller,
      builder: (_, _, _) => Stack(
        children: [
          // Hidden form
          Positioned(
            top: 0, bottom: 0, left: 0, right: 0,
            child: Opacity(
              opacity: 0,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: input.controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: input.onChanged,
                readOnly: true,
                validator: input.validator,
              ),
            ),
          ),
          // Main
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MergeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _backgroundColor(context),
                    border: Border.all(
                      width: defaultBorder.borderSide.width,
                      color: defaultBorder.borderSide.color,
                    ),
                    borderRadius: defaultBorder.borderRadius,
                  ),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          input.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: _softLabel(context),
                          ),
                        ),
                        Text(
                          input.active.label,
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                    trailing: IgnorePointer(
                      ignoring: true,
                      child: CupertinoSwitch(value: input.active.value == input.element.last.value, onChanged: (_) {},),
                    ),
                    onTap: () async {
                      if (input.active.value == input.element.last.value) {
                        input.active = input.element.first.clone;
                      }
                      else {
                        input.active = input.element.last.clone;
                      }

                      input.controller.text = input.active.label;
                    },
                  ),
                ),
              ),
              // Error Message
              ValueListenableBuilder(
                valueListenable: input.validate,
                builder: (_, value, _) {
                  if (value != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: InputErrorMessage(text: value),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InputTextFieldState extends StatefulWidget {
  final InputTypeText input;

  const InputTextFieldState({
    super.key,
    required this.input,
  });

  @override
  State<StatefulWidget> createState() => InputTextFieldPageState();
}

class InputTextFieldPageState extends State<InputTextFieldState> {
  late final InputTypeText input = widget.input;

  void rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: input.controller,
      builder: (_, _, _) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: input.controller,
            decoration: input.decoration.copyWith(
              fillColor: _backgroundColor(context),
              suffixIcon: input.suffixIcon?.call(rebuild, input),
            ),
            focusNode: input.focusNode,
            minLines: input.minLines,
            obscureText: input.obscureText,
            onChanged: input.onChanged,
            textInputAction: input.next != null ? TextInputAction.next:null,
            validator: input.validator,
            onEditingComplete: (){
              if (input.next != null) {
                FocusScope.of(context).requestFocus(input.next);
              }
              else {
                FocusScope.of(context).unfocus();
              }
            },
          ),
          ValueListenableBuilder(
            valueListenable: input.validate,
            builder: (_, value, _) {
              if (value != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: InputErrorMessage(text: value),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}














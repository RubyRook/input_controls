import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

final decorationTextForm = InputDecoration(
  labelStyle: const TextStyle(height: 1.2),
  contentPadding: const EdgeInsets.fromLTRB(15, 9, 15, 9),
  filled: true,
  fillColor: Colors.white,
  border: defaultBorder,
  enabledBorder: defaultBorder,
  focusedBorder: defaultBorder,
  errorBorder: errorBorder,
  focusedErrorBorder: errorBorder,
  errorStyle: TextStyle(color: Colors.red.shade800, fontSize: 12, height: 1.2,),
);

final decorationTextFormSelect = decorationTextForm.copyWith(suffixIcon: const Icon(
  Icons.arrow_drop_down_outlined,
  color: Colors.grey,
  size: 22,
),);

final defaultBorder = OutlineInputBorder(
  borderSide: BorderSide(width: .75, color: const Color(0xFF707070).withAlpha(900),),
  borderRadius: BorderRadius.circular(4),
);

final errorBorder = OutlineInputBorder(
  borderSide: const BorderSide(width: .75, color: Colors.red,),
  borderRadius: BorderRadius.circular(4),
);

class OutlineInputBorder extends InputBorder {
  /// Creates an outline border for an [InputDecorator].
  ///
  /// The [borderSide] parameter defaults to [BorderSide.none] (it must not be
  /// null). Applications typically do not specify a [borderSide] parameter
  /// because the input decorator substitutes its own, using [copyWith], based
  /// on the current theme and [InputDecorator.isFocused].
  ///
  /// The [borderRadius] parameter defaults to a value where the all corners
  /// corners have a circular radius of 4.0. The [borderRadius]
  /// parameter must not be null.
  const OutlineInputBorder({
    super.borderSide = const BorderSide(),
    this.borderRadius = const BorderRadius.all(Radius.circular(4,),),
  });

  /// When this border is used with a filled input decorator, see
  /// [InputDecoration.filled], the border radius defines the shape
  /// of the background fill as well as the bottom left and right
  /// edges of the underline itself.
  final BorderRadius borderRadius;

  // This function can be ignore
  static bool _cornersAreCircular(BorderRadius borderRadius) {
    return borderRadius.topLeft.x == borderRadius.topLeft.y
        && borderRadius.bottomLeft.x == borderRadius.bottomLeft.y
        && borderRadius.topRight.x == borderRadius.topRight.y
        && borderRadius.bottomRight.x == borderRadius.bottomRight.y;
  }

  @override
  bool get isOutline => false;

  // This function can be ignore
  @override
  OutlineInputBorder copyWith({ BorderSide? borderSide, BorderRadius? borderRadius }) {
    return OutlineInputBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  // This function can be ignore
  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(borderSide.width);
  }

  // This function can be ignore
  @override
  OutlineInputBorder scale(double t) {
    return OutlineInputBorder(borderSide: borderSide.scale(t));
  }

  // This function can be ignore
  @override
  Path getInnerPath(Rect rect, { TextDirection? textDirection }) {
    return Path()
      ..addRect(Rect.fromLTWH(rect.left, rect.top, rect.width, math.max(0.0, rect.height - borderSide.width)));
  }

  // This function can be ignore
  @override
  Path getOuterPath(Rect rect, { TextDirection? textDirection }) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  // This function can be ignore
  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is UnderlineInputBorder) {
      return UnderlineInputBorder(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  // This function can be ignore
  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is UnderlineInputBorder) {
      return UnderlineInputBorder(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  /// Draw a rounded rectangle around [rect] using [borderRadius].
  ///
  /// The [borderSide] defines the line's color and weight.
  @override
  void paint(
      Canvas canvas,
      Rect rect, {
        double? gapStart,
        double gapExtent = 0.0,
        double gapPercentage = 0.0,
        TextDirection? textDirection,
      }){
    assert(gapPercentage >= 0.0 && gapPercentage <= 1.0);
    assert(_cornersAreCircular(borderRadius));

    final Paint paint = borderSide.toPaint();
    final RRect outer = borderRadius.toRRect(rect);
    final RRect center = outer.deflate(borderSide.width / 2.0);
    canvas.drawRRect(center, paint);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is OutlineInputBorder
        && other.borderSide == borderSide
        && other.borderRadius == borderRadius;
  }
  // bool operator ==(Object other) {
  //   if (identical(this, other)) {
  //     return true;
  //   }
  //   if (other.runtimeType != runtimeType) {
  //     return false;
  //   }
  //   return other is InputBorder && other.borderSide == borderSide;
  // }

  @override
  int get hashCode => Object.hash(borderSide, borderRadius);
// int get hashCode => borderSide.hashCode;
}

class InputErrorMessage extends StatelessWidget {
  final String text;
  const InputErrorMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return _WidgetIconText(
      iconData: Icons.error,
      text: text,

      fontSize: 12,
      color: Colors.red.shade800,
    );
  }

}

/// Much more fit with odd number. Exp: fontSize 15, 17 or 19
class _WidgetIconText extends StatelessWidget {
  const _WidgetIconText({
    required this.iconData,
    required this.text,
    this.fontSize = 15,
    this.color,
  });

  final IconData iconData;
  final String text;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    const double iconScale = 1.0;
    const double lineHeight = 1.5;
    const double spaceBetween = 4.0;

    // Specific on build in icon only (Icons and CupertinoIcons)
    final iconGap = fontSize*(4/24);
    final topSpace = (lineHeight - 1)*fontSize;

    final style = TextStyle(
      color: color,
      height: lineHeight,
      fontSize: fontSize,
    );

    List<Widget> children = [
      // Icon
      Container(
        width: fontSize,
        padding: EdgeInsets.only(top: topSpace-iconGap),
        child: Container(
          color: Colors.transparent,
          width: fontSize,
          height: fontSize,
          child: Transform.scale(
            scale: iconScale,
            origin: const Offset(0, 1),
            alignment: Alignment.centerLeft,
            child: Icon(
              iconData,
              size: fontSize,
              color: color,
            ),
          ),
        ),
      ),
      // Space between
      Gap(spaceBetween),
      // Text
      Flexible(
        child: Text(text, style: style, textAlign: TextAlign.left,),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

}
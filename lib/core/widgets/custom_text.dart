import 'package:flutter/material.dart';
class CustomText extends StatelessWidget {
  final String text; final TextStyle? style; final TextAlign? textAlign;
  final int? maxLines; final TextOverflow? overflow; final Color? color;
  final double? fontSize; final FontWeight? fontWeight; final String? fontFamily;
  const CustomText(this.text,{super.key,this.style,this.textAlign,this.maxLines,this.overflow,this.color,this.fontSize,this.fontWeight,this.fontFamily});
  @override
  Widget build(BuildContext context) {
    final base = (style ?? DefaultTextStyle.of(context).style).copyWith(
      color: color, fontSize: fontSize, fontWeight: fontWeight,
      fontFamily: fontFamily ?? 'Cairo',
    );
    return Text(text, style: base, textAlign: textAlign, maxLines: maxLines, overflow: overflow);
  }
}

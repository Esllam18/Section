import 'package:flutter/material.dart';
class Gap extends StatelessWidget {
  final double size;
  final bool h;
  const Gap(this.size, {super.key, this.h = false});
  const Gap.h(this.size, {super.key}) : h = true;
  @override
  Widget build(BuildContext context) => h ? SizedBox(width: size) : SizedBox(height: size);
}

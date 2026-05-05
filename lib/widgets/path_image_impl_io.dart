import 'dart:io';

import 'package:flutter/material.dart';

Widget buildPathImage({
  required String path,
  required BoxFit fit,
  double? width,
  double? height,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.file(
    File(path),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: errorBuilder,
  );
}

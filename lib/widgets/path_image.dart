import 'package:flutter/material.dart';

import 'path_image_impl_io.dart'
    if (dart.library.html) 'path_image_impl_web.dart' as impl;

class PathImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const PathImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return impl.buildPathImage(
      path: path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }
}

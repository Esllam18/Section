import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/widgets/shimmer_widget.dart';
class CachedImageWidget extends StatelessWidget {
  final String? imageUrl; final double? width; final double? height;
  final BoxFit fit; final double borderRadius;
  const CachedImageWidget({super.key, required this.imageUrl, this.width, this.height, this.fit = BoxFit.cover, this.borderRadius = 0});
  @override Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return _placeholder();
    return ClipRRect(borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(imageUrl: imageUrl!, width: width, height: height, fit: fit,
        placeholder: (_, __) => ShimmerWidget(width: width ?? double.infinity, height: height ?? 100, borderRadius: borderRadius),
        errorWidget: (_, __, ___) => _placeholder()));
  }
  Widget _placeholder() => Container(width: width, height: height,
    decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(borderRadius)),
    child: const Icon(Icons.image_outlined, color: AppColors.dividerLight, size: 32));
}

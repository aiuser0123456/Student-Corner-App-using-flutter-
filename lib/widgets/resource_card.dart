import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/resource.dart';
import '../theme/app_theme.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback onToggleSave;

  const ResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: resource.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: resource.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.muted,
                        child: const Icon(Icons.image_not_supported_outlined,
                            color: AppColors.mutedForeground),
                      ),
                      placeholder: (_, __) => Container(
                        color: AppColors.muted,
                      ),
                    )
                  : Container(
                      color: AppColors.muted,
                      child: const Icon(Icons.menu_book_outlined,
                          size: 40, color: AppColors.mutedForeground),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _tag(resource.category, AppColors.primary),
                      _tag(resource.subject, AppColors.accent, dark: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          resource.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? AppColors.primary : AppColors.mutedForeground,
                        ),
                        onPressed: onToggleSave,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.mutedForeground, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, Color color, {bool dark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: dark ? Colors.orange.shade800 : color,
        ),
      ),
    );
  }
}

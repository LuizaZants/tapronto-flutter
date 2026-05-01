import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/meal_model.dart';
import '../pages/detail_page.dart';
import '../services/meal_service.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final double? width;

  const MealCard({super.key, required this.meal, this.width});

  @override
  Widget build(BuildContext context) {
    final name = MealService.translateDish(meal.name);
    final area = meal.area != null ? MealService.areaTranslations[meal.area] ?? meal.area! : null;
    final cat  = meal.category != null ? MealService.categoryTranslations[meal.category] ?? meal.category! : null;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailPage(mealId: meal.id))),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagem ──────────────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      meal.thumb,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, prog) {
                        if (prog == null) return child;
                        return Container(
                          color: AppTheme.divider,
                          child: const Center(
                              child: Icon(Icons.restaurant, color: AppTheme.textMuted, size: 28)),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.divider,
                        child: const Icon(Icons.broken_image, color: AppTheme.textMuted),
                      ),
                    ),
                    // Gradiente suave no bottom
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.22)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Info ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (area != null || cat != null)
                    Text(
                      [if (area != null) area, if (cat != null) cat].join(' · ').toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 9,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Ver receita →',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

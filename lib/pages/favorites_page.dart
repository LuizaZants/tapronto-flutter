import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_theme.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';
import '../widgets/section_header.dart';
import 'detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'MINHAS RECEITAS'),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('favoritos').snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) return const Center(child: Text('Erro ao carregar'));
                  if (snap.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));

                  final docs = snap.data!.docs;
                  if (docs.isEmpty) return _buildEmpty();

                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '${docs.length} receita${docs.length > 1 ? 's' : ''} salva${docs.length > 1 ? 's' : ''}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(color: AppTheme.divider, height: 1),
                        itemBuilder: (ctx, i) {
                          final data = docs[i].data() as Map<String, dynamic>;
                          final meal = Meal(
                            id: data['idMeal'] ?? '',
                            name: data['strMeal'] ?? '',
                            thumb: data['strMealThumb'] ?? '',
                            category: data['strCategory'],
                            area: data['strArea'],
                          );
                          return _buildItem(ctx, meal, docs[i].id);
                        },
                      ),
                    ),
                  ]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, Meal meal, String docId) {
    final name = MealService.translateDish(meal.name);
    final area = meal.area != null ? MealService.areaTranslations[meal.area] ?? meal.area! : null;
    final cat  = meal.category != null ? MealService.categoryTranslations[meal.category] ?? meal.category! : null;
    final meta = [if (area != null) area, if (cat != null) cat].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        // Thumbnail
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => DetailPage(mealId: meal.id))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(meal.thumb, width: 80, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: AppTheme.divider)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (meta.isNotEmpty) Text(meta.toUpperCase(),
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 0.8)),
            const SizedBox(height: 3),
            Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Georgia', fontSize: 15,
                    fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => DetailPage(mealId: meal.id))),
              child: const Text('Ver receita →',
                  style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 18),
          onPressed: () => FirebaseFirestore.instance.collection('favoritos').doc(docId).delete(),
        ),
      ]),
    );
  }

  Widget _buildEmpty() => const Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('🍽️', style: TextStyle(fontSize: 52)),
      SizedBox(height: 12),
      Text('Nenhuma receita salva ainda',
          style: TextStyle(fontFamily: 'Georgia', fontSize: 18,
              fontWeight: FontWeight.w700, color: AppTheme.textDark)),
      SizedBox(height: 6),
      Text('Explore e salve suas favoritas',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
    ]),
  );
}

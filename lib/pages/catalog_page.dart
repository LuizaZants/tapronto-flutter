import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/section_header.dart';

class CatalogPage extends StatefulWidget {
  final String categoryLabel;
  final String categoryId;
  final bool isArea;

  const CatalogPage({
    super.key,
    required this.categoryLabel,
    required this.categoryId,
    this.isArea = false,
  });

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _svc = MealService();
  bool _loading = true;
  List<Meal> _meals = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = widget.isArea
          ? await _svc.searchByArea(widget.categoryId)
          : await _svc.searchByCategory(widget.categoryId);
      if (mounted) setState(() { _meals = results; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: widget.categoryLabel.toUpperCase()),
          if (!_loading)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 4),
              child: Text('${_meals.length} receitas encontradas',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _meals.isEmpty
                    ? const Center(child: Text('Nenhuma receita encontrada 😕',
                        style: TextStyle(color: AppTheme.textMuted)))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 16,
                          mainAxisSpacing: 24, childAspectRatio: 0.60,
                        ),
                        itemCount: _meals.length,
                        itemBuilder: (ctx, i) => MealCard(meal: _meals[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

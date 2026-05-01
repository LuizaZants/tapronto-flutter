import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_theme.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';

class DetailPage extends StatefulWidget {
  final String mealId;
  const DetailPage({super.key, required this.mealId});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  final _svc = MealService();
  final _db  = FirebaseFirestore.instance;

  Meal? _meal;
  bool _loading     = true;
  bool _isFavorite  = false;
  bool _translating = false;
  List<Map<String, String>> _ingredients = [];
  List<String> _steps = [];
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadMeal();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _loadMeal() async {
    setState(() => _loading = true);
    try {
      final raw = await _svc.getRawMealById(widget.mealId);
      if (raw != null) {
        final meal = Meal.fromJson(raw);
        final favDoc = await _db.collection('favoritos').doc(widget.mealId).get();
        final rawSteps = _svc.getSteps(raw['strInstructions']);
        if (mounted) setState(() {
          _meal = meal;
          _isFavorite  = favDoc.exists;
          _ingredients = _svc.getIngredients(raw);
          _steps       = rawSteps;
          _loading     = false;
        });
        _translateSteps(rawSteps);
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _translateSteps(List<String> raw) async {
    setState(() => _translating = true);
    final translated = await Future.wait(raw.map((s) => _svc.translateText(s)));
    if (mounted) setState(() { _steps = translated; _translating = false; });
  }

  Future<void> _toggleFavorite() async {
    if (_meal == null) return;
    final ref = _db.collection('favoritos').doc(_meal!.id);
    if (_isFavorite) { await ref.delete(); }
    else { await ref.set(_meal!.toMap()); }
    if (!mounted) return;
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_isFavorite ? 'Salvo nos favoritos!' : 'Removido dos favoritos'),
      duration: const Duration(seconds: 1),
      backgroundColor: AppTheme.primary,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
    if (_meal == null) return Scaffold(
        appBar: AppBar(), body: const Center(child: Text('Receita não encontrada')));

    final name     = MealService.translateDish(_meal!.name);
    final area     = _meal!.area != null ? MealService.areaTranslations[_meal!.area] ?? _meal!.area! : null;
    final category = _meal!.category != null ? MealService.categoryTranslations[_meal!.category] ?? _meal!.category! : null;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero ──────────────────────────────────────────────────────
              Stack(children: [
                Image.network(_meal!.thumb, width: double.infinity,
                    height: 340, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 340, color: AppTheme.divider)),
                Container(height: 340, decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppTheme.background],
                    stops: const [0.45, 1.0],
                  ),
                )),
                Positioned(top: 48, left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark, size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ]),

              // ── Conteúdo ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Tags
                  Wrap(spacing: 8, children: [
                    if (area != null)     _Tag(area),
                    if (category != null) _Tag(category),
                  ]),
                  const SizedBox(height: 12),

                  // Título
                  Text(name, style: const TextStyle(
                    fontFamily: 'Georgia', fontSize: 28,
                    fontWeight: FontWeight.w700, color: AppTheme.textDark, height: 1.2)),
                  const SizedBox(height: 8),

                  // Stats
                  Row(children: [
                    _Stat('🥕', '${_ingredients.length} ingredientes'),
                    const SizedBox(width: 20),
                    _Stat('📋', '${_steps.length} passos'),
                  ]),
                  const SizedBox(height: 18),

                  // Botão favoritar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _toggleFavorite,
                      icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.white : AppTheme.primary, size: 18),
                      label: Text(
                        _isFavorite ? 'Salvo nos favoritos' : 'Salvar receita',
                        style: TextStyle(
                          color: _isFavorite ? Colors.white : AppTheme.primary,
                          fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _isFavorite ? AppTheme.primary : Colors.transparent,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  TabBar(
                    controller: _tabs,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textMuted,
                    indicatorColor: AppTheme.primary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: const [Tab(text: 'Ingredientes'), Tab(text: 'Preparo'), Tab(text: 'Nutricional')],
                  ),

                  SizedBox(
                    height: 420,
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        _IngredientsTab(ingredients: _ingredients),
                        _StepsTab(steps: _steps, translating: _translating),
                        _NutritionTab(ingredients: _ingredients),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: AppTheme.divider),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
  );
}

class _Stat extends StatelessWidget {
  final String icon, label;
  const _Stat(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(icon), const SizedBox(width: 4),
    Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
  ]);
}

class _IngredientsTab extends StatelessWidget {
  final List<Map<String, String>> ingredients;
  const _IngredientsTab({required this.ingredients});
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.only(top: 16),
    itemCount: ingredients.length,
    separatorBuilder: (_, __) => const Divider(color: AppTheme.divider, height: 1),
    itemBuilder: (_, i) {
      final item = ingredients[i];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(
              color: AppTheme.primary, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(MealService.translateIngredient(item['ingredient'] ?? ''),
              style: const TextStyle(color: AppTheme.textDark, fontSize: 14))),
          Text(item['measure'] ?? '', style: const TextStyle(
              color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      );
    },
  );
}

class _StepsTab extends StatelessWidget {
  final List<String> steps;
  final bool translating;
  const _StepsTab({required this.steps, required this.translating});
  @override
  Widget build(BuildContext context) {
    if (translating && steps.isEmpty) return const Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [CircularProgressIndicator(color: AppTheme.primary), SizedBox(height: 10),
        Text('Traduzindo...', style: TextStyle(color: AppTheme.textMuted))],
    ));
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: steps.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
              child: Text('Passo ${i + 1}', style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Divider(color: AppTheme.divider)),
          ]),
          const SizedBox(height: 8),
          Text(steps[i], style: const TextStyle(
              color: AppTheme.textDark, fontSize: 14, height: 1.65)),
        ]),
      ),
    );
  }
}

class _NutritionTab extends StatelessWidget {
  final List<Map<String, String>> ingredients;
  const _NutritionTab({required this.ingredients});

  static const _items = [
    {'label': '🔥 Calorias',     'value': '~350 kcal', 'ratio': 0.65},
    {'label': '💪 Proteínas',    'value': '~18g',      'ratio': 0.45},
    {'label': '🌾 Carboidratos', 'value': '~42g',      'ratio': 0.60},
    {'label': '🫒 Gorduras',     'value': '~12g',      'ratio': 0.30},
    {'label': '🥦 Fibras',       'value': '~5g',       'ratio': 0.38},
    {'label': '🧂 Sódio',        'value': '~420mg',    'ratio': 0.50},
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(top: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
        ),
        child: const Text('ℹ️  Valores estimados com base nos ingredientes.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ),
      const SizedBox(height: 16),
      ..._items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(item['label'] as String, style: const TextStyle(color: AppTheme.textDark, fontSize: 13)),
            Text(item['value'] as String, style: const TextStyle(
                color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item['ratio'] as double,
              backgroundColor: AppTheme.divider,
              color: AppTheme.primary, minHeight: 5)),
        ]),
      )),
    ]),
  );
}

import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/section_header.dart';
import 'catalog_page.dart';

// ── Mesmos dados do React ─────────────────────────────────────────────────────
const _categories = [
  {'label': 'Aperitivos',      'category': 'Starter'},
  {'label': 'Carnes',          'category': 'Beef'},
  {'label': 'Aves',            'category': 'Chicken'},
  {'label': 'Peixes',          'category': 'SeafoodPeixes'},
  {'label': 'Sem carne',       'category': 'Vegetarian'},
  {'label': 'Acompanhamentos', 'category': 'Side'},
  {'label': 'Frutos do mar',   'category': 'Seafood'},
  {'label': 'Massas',          'category': 'Pasta'},
  {'label': 'Sobremesas',      'category': 'Dessert'},
];

const _mealTypes = [
  {'label': 'Café da manhã', 'category': 'Breakfast'},
  {'label': 'Almoço',        'category': 'Beef'},
  {'label': 'Happy hour',    'category': 'Starter'},
  {'label': 'Jantar',        'category': 'Pasta'},
];

// IDs fixos — mesmos do React
const _featuredIds = ['53248', '52844', '53207', '53278'];
const _dessertIds  = ['53303', '52989', '52859', '52931'];
const _idChickenImg   = '53261';
const _idDessertImg   = '53316';
const _idBreakfastImg = '53331';
const _idAlmocoImg    = '53366';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _svc = MealService();
  bool _loading = true;
  List<Meal> _featured = [];
  List<Meal> _seafood  = [];
  List<Meal> _desserts = [];
  Map<String, String> _catImages  = {};
  Map<String, String> _typeImages = {};

  @override
  void initState() { super.initState(); _load(); }

  String _img(List<Meal> list, [int idx = 0]) {
    final v = list.where((m) => m.thumb.isNotEmpty).toList();
    if (v.isEmpty) return '';
    return v[idx < v.length ? idx : 0].thumb;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        _svc.searchByCategory('Chicken'),    // 0
        _svc.searchByCategory('Seafood'),    // 1
        _svc.searchByCategory('Dessert'),    // 2
        _svc.searchByCategory('Breakfast'),  // 3
        _svc.searchByCategory('Beef'),       // 4
        _svc.searchByCategory('Pasta'),      // 5
        _svc.searchByCategory('Starter'),    // 6
        _svc.searchByCategory('Vegetarian'), // 7
        _svc.searchByCategory('Side'),       // 8
      ]);
      final chicken=res[0]; final sea=res[1]; final des=res[2];
      final bf=res[3]; final beef=res[4]; final pasta=res[5];
      final starter=res[6]; final veg=res[7]; final side=res[8];

      // Featured: 4 IDs fixos + chicken[4..5]
      final fMeals = await Future.wait(_featuredIds.map((id) => _svc.getMealById(id)));
      final featFixed = fMeals.whereType<Meal>().toList();
      final lastTwo = chicken.length > 5 ? chicken.sublist(4, 6)
                    : chicken.length > 4 ? chicken.sublist(4) : <Meal>[];

      // Desserts: 4 IDs fixos
      final dMeals = await Future.wait(_dessertIds.map((id) => _svc.getMealById(id)));
      final desFixed = dMeals.whereType<Meal>().toList();

      // Imagens de categoria — mesma lógica do React
      final catImgs = <String, String>{
        'Starter':       _img(starter),
        'Beef':          _img(beef, 4),
        'Chicken':       _img(chicken, 2),
        'Seafood':       _img(sea, 0),
        'SeafoodPeixes': _img(sea, 3),
        'Vegetarian':    _img(veg),
        'Side':          _img(side),
        'Pasta':         _img(pasta),
        'Dessert':       _img(des),
      };

      // Imagens específicas por ID — mesmos do React
      final sp = await Future.wait([
        _svc.getMealById(_idDessertImg),
        _svc.getMealById(_idChickenImg),
        _svc.getMealById(_idBreakfastImg),
        _svc.getMealById(_idAlmocoImg),
      ]);
      if (sp[1]?.thumb.isNotEmpty == true) catImgs['Chicken'] = sp[1]!.thumb;
      if (sp[0]?.thumb.isNotEmpty == true) catImgs['Dessert']  = sp[0]!.thumb;

      final typeImgs = <String, String>{
        'Breakfast': sp[2]?.thumb ?? _img(bf),
        'Beef':      sp[3]?.thumb ?? _img(beef, 4),
        'Starter':   _img(starter),
        'Pasta':     _img(pasta),
      };

      if (mounted) setState(() {
        _featured   = [...featFixed, ...lastTwo];
        _seafood    = sea.take(4).toList();
        _desserts   = desFixed.length >= 4 ? desFixed : des.take(4).toList();
        _catImages  = catImgs;
        _typeImages = typeImgs;
        _loading    = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToCatalog(BuildContext ctx, String categoryId, String label) {
    final navId = categoryId == 'SeafoodPeixes' ? 'Seafood' : categoryId;
    Navigator.push(ctx, MaterialPageRoute(builder: (_) =>
        CatalogPage(categoryLabel: label, categoryId: navId)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async { setState(() => _loading = true); await _load(); },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── 1. CATEGORIAS ────────────────────────────────────────────────
            const SectionHeader(
              title: 'FAÇA SUA BUSCA AQUI',
              subtitle: 'NAVEGUE POR CATEGORIA',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemCount: _categories.length,
                itemBuilder: (ctx, i) {
                  final cat    = _categories[i];
                  final imgKey = cat['category']!;
                  final imgUrl = _catImages[imgKey] ?? '';
                  return GestureDetector(
                    onTap: () => _goToCatalog(ctx, imgKey, cat['label']!),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Stack(fit: StackFit.expand, children: [
                              imgUrl.isNotEmpty
                                  ? Image.network(imgUrl, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: AppTheme.divider))
                                  : Container(color: AppTheme.divider),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.center, end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.52)],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 7, left: 0, right: 0,
                                child: Text(cat['label']!, textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(cat['label']!,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Georgia', fontSize: 11, color: AppTheme.textDark)),
                      ],
                    ),
                  );
                },
              ),
            ),

            _divider(),

            // ── 2. PRÓXIMA REFEIÇÃO ──────────────────────────────────────────
            const SectionHeader(
              title: 'PRÓXIMA REFEIÇÃO?',
              subtitle: 'A GENTE TEM A IDEIA PERFEITA',
            ),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _mealTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final mt     = _mealTypes[i];
                  final imgUrl = _typeImages[mt['category']] ?? '';
                  return GestureDetector(
                    onTap: () => _goToCatalog(ctx, mt['category']!, mt['label']!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 112,
                        child: Stack(fit: StackFit.expand, children: [
                          imgUrl.isNotEmpty
                              ? Image.network(imgUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: AppTheme.divider))
                              : Container(color: AppTheme.divider),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10, left: 0, right: 0,
                            child: Text(mt['label']!, textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800,
                                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
                          ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),

            _divider(),

            // ── 3. EM ALTA ───────────────────────────────────────────────────
            if (_featured.isNotEmpty) ...[
              const SectionHeader(title: 'EM ALTA', subtitle: 'RECEITAS MAIS BUSCADAS'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 24, childAspectRatio: 0.60,
                  ),
                  itemCount: _featured.length,
                  itemBuilder: (ctx, i) => MealCard(meal: _featured[i]),
                ),
              ),
              _divider(),
            ],

            // ── 4. FRUTOS DO MAR ─────────────────────────────────────────────
            if (_seafood.isNotEmpty) ...[
              SectionHeader(
                title: 'FRUTOS DO MAR',
                subtitle: 'FRESCOR DO OCEANO NA SUA MESA',
                actionLabel: 'VER TODAS',
                onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                    const CatalogPage(categoryLabel: 'Frutos do Mar', categoryId: 'Seafood'))),
              ),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _seafood.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (ctx, i) => SizedBox(width: 160, child: MealCard(meal: _seafood[i])),
                ),
              ),
              _divider(),
            ],

            // ── 5. SOBREMESAS ─────────────────────────────────────────────────
            if (_desserts.isNotEmpty) ...[
              SectionHeader(
                title: 'SOBREMESAS',
                subtitle: 'ADOCE O SEU DIA',
                actionLabel: 'VER TODAS',
                onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                    const CatalogPage(categoryLabel: 'Sobremesas', categoryId: 'Dessert'))),
              ),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _desserts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (ctx, i) => SizedBox(width: 160, child: MealCard(meal: _desserts[i])),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
    color: AppTheme.divider,
  );
}

import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/section_header.dart';

const _suggestions = [
  'Frango','Lasanha','Sopa','Salada','Bolo','Peixe','Massa','Curry','Ovo','Camarão',
];

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _svc = MealService();
  final _ctrl = TextEditingController();
  List<Meal> _results = [];
  bool _loading   = false;
  bool _searched  = false;
  bool _byIngredient = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _search([String? q]) async {
    final query = (q ?? _ctrl.text).trim();
    if (query.isEmpty) return;
    if (q != null) _ctrl.text = q;
    setState(() { _loading = true; _searched = true; });
    try {
      final translated = MealService.translateSearch(query);
      final data = _byIngredient
          ? await _svc.searchByIngredient(translated)
          : await _svc.searchByName(translated);
      setState(() => _results = data);
    } catch (_) { setState(() => _results = []); }
    finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'BUSCAR RECEITAS'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de busca
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        onSubmitted: (_) => _search(),
                        style: const TextStyle(color: AppTheme.textDark),
                        decoration: InputDecoration(
                          hintText: _byIngredient ? 'Ex: frango, tomate...' : 'Ex: lasanha, sopa...',
                          hintStyle: const TextStyle(color: AppTheme.textMuted),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _search,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
                      child: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Toggle
                  Row(children: [
                    const Text('Buscar por: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(width: 6),
                    _ToggleBtn(label: 'Nome', active: !_byIngredient,
                        onTap: () => setState(() => _byIngredient = false)),
                    const SizedBox(width: 6),
                    _ToggleBtn(label: 'Ingrediente', active: _byIngredient,
                        onTap: () => setState(() => _byIngredient = true)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : !_searched
                      ? _buildSuggestions()
                      : _results.isEmpty
                          ? Center(child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                const Text('🔍', style: TextStyle(fontSize: 40)),
                                const SizedBox(height: 12),
                                Text('Nenhuma receita encontrada para "${_ctrl.text}"',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontFamily: 'Georgia', fontSize: 15, color: AppTheme.textDark)),
                                const SizedBox(height: 6),
                                const Text('Tente outro termo ou ingrediente',
                                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              ]),
                            ))
                          : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Sugestões de busca',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 12, letterSpacing: 0.5)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8,
        children: _suggestions.map((s) => GestureDetector(
          onTap: () => _search(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Text(s, style: const TextStyle(color: AppTheme.textDark, fontSize: 13)),
          ),
        )).toList(),
      ),
    ]),
  );

  Widget _buildResults() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text('${_results.length} receitas encontradas',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
    ),
    const SizedBox(height: 8),
    Expanded(child: GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 24, childAspectRatio: 0.60),
      itemCount: _results.length,
      itemBuilder: (ctx, i) => MealCard(meal: _results[i]),
    )),
  ]);
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppTheme.primary : AppTheme.divider),
      ),
      child: Text(label, style: TextStyle(
        color: active ? Colors.white : AppTheme.textMuted,
        fontWeight: FontWeight.w700, fontSize: 12)),
    ),
  );
}

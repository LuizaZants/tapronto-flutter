import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';

class MealService {
  static const String _base = 'https://www.themealdb.com/api/json/v1/1';

  // ── Traduções ─────────────────────────────────────────────────────────────
  static const Map<String, String> categoryTranslations = {
    'Beef':'Carne Bovina','Chicken':'Frango','Dessert':'Sobremesas',
    'Lamb':'Cordeiro','Miscellaneous':'Variados','Pasta':'Massas',
    'Pork':'Porco','Seafood':'Frutos do Mar','Side':'Acompanhamentos',
    'Starter':'Aperitivos','Vegan':'Vegano','Vegetarian':'Sem Carne',
    'Breakfast':'Café da Manhã','Goat':'Cabrito',
  };

  static const Map<String, String> areaTranslations = {
    'Italian':'Italiana','Brazilian':'Brasileira','Japanese':'Japonesa',
    'Mexican':'Mexicana','American':'Americana','Indian':'Indiana',
    'French':'Francesa','Chinese':'Chinesa','Thai':'Tailandesa',
    'Greek':'Grega','Spanish':'Espanhola','British':'Britânica',
    'Canadian':'Canadense','Moroccan':'Marroquina','Russian':'Russa',
    'Turkish':'Turca','Vietnamese':'Vietnamita','Filipino':'Filipina',
    'Jamaican':'Jamaicana','Croatian':'Croata','Dutch':'Holandesa',
    'Egyptian':'Egípcia','Irish':'Irlandesa','Kenyan':'Queniana',
    'Malaysian':'Malaia','Polish':'Polonesa','Portuguese':'Portuguesa',
    'Unknown':'Desconhecida',
  };

  static const Map<String, String> _ptToEn = {
    'frango':'chicken','galinha':'chicken','carne':'beef','porco':'pork',
    'peixe':'fish','salmão':'salmon','camarão':'shrimp','massa':'pasta',
    'macarrão':'pasta','espaguete':'spaghetti','lasanha':'lasagna',
    'risoto':'risotto','sopa':'soup','salada':'salad','bolo':'cake',
    'torta':'pie','pizza':'pizza','hamburguer':'burger','curry':'curry',
    'ovo':'egg','ovos':'eggs','queijo':'cheese','tomate':'tomato',
    'batata':'potato','arroz':'rice','feijão':'beans','sobremesa':'dessert',
    'pudim':'pudding','panqueca':'pancake','tacos':'tacos',
    'cordeiro':'lamb','atum':'tuna','bacalhau':'cod',
  };

  static const Map<String, String> _ingredientTranslations = {
    'chicken':'Frango','beef':'Carne Bovina','lamb':'Cordeiro','pork':'Porco',
    'bacon':'Bacon','sausage':'Linguiça','fish':'Peixe','salmon':'Salmão',
    'tuna':'Atum','shrimp':'Camarão','prawn':'Camarão','crab':'Caranguejo',
    'oil':'Azeite','olive oil':'Azeite de Oliva','butter':'Manteiga',
    'cream':'Creme de Leite','milk':'Leite','cheese':'Queijo','egg':'Ovo',
    'eggs':'Ovos','flour':'Farinha','sugar':'Açúcar','salt':'Sal',
    'pepper':'Pimenta','black pepper':'Pimenta Preta','onion':'Cebola',
    'garlic':'Alho','ginger':'Gengibre','tomato':'Tomate','potato':'Batata',
    'potatoes':'Batatas','carrot':'Cenoura','mushroom':'Cogumelo',
    'spinach':'Espinafre','broccoli':'Brócolis','corn':'Milho','peas':'Ervilha',
    'beans':'Feijão','lentils':'Lentilhas','chickpeas':'Grão-de-Bico',
    'rice':'Arroz','pasta':'Massa','bread':'Pão','soy sauce':'Molho Shoyu',
    'worcestershire sauce':'Molho Inglês','vinegar':'Vinagre','lemon':'Limão',
    'lime':'Lima','honey':'Mel','chocolate':'Chocolate','vanilla':'Baunilha',
    'cinnamon':'Canela','cumin':'Cominho','paprika':'Páprica','oregano':'Orégano',
    'basil':'Manjericão','thyme':'Tomilho','rosemary':'Alecrim','parsley':'Salsinha',
    'cilantro':'Coentro','chili':'Pimenta','curry powder':'Curry em Pó',
    'chicken stock':'Caldo de Frango','beef stock':'Caldo de Carne',
    'white wine':'Vinho Branco','red wine':'Vinho Tinto','water':'Água',
    'baking powder':'Fermento em Pó','cornstarch':'Amido de Milho',
    'olive':'Azeitona','mozzarella':'Mussarela','parmesan':'Parmesão',
    'coconut milk':'Leite de Coco','almond':'Amêndoa','walnut':'Nozes',
    'peanut':'Amendoim','sesame':'Gergelim','strawberry':'Morango',
    'banana':'Banana','apple':'Maçã','mango':'Manga','avocado':'Abacate',
    'sweet potato':'Batata Doce','spaghetti':'Espaguete','noodles':'Macarrão',
  };

  static const _keepOriginal = [
    'sushi','ramen','tempura','udon','miso','teriyaki','tikka','masala',
    'biryani','dal','naan','paella','gazpacho','churros','croissant','quiche',
    'ratatouille','tiramisu','bruschetta','gnocchi','guacamole','quesadilla',
    'enchilada','stroganoff','goulash','hummus','falafel','shawarma','kebab',
    'pad thai','pho','satay','jollof','yakisoba',
  ];

  static String translateDish(String name) {
    final lower = name.toLowerCase();
    if (_keepOriginal.any((k) => lower.contains(k))) return name;
    const parts = {
      'chicken':'Frango','beef':'Carne Bovina','lamb':'Cordeiro','pork':'Porco',
      'pasta':'Massa','spaghetti':'Espaguete','lasagna':'Lasanha','lasagne':'Lasanha',
      'risotto':'Risoto','soup':'Sopa','salad':'Salada','cake':'Bolo','pie':'Torta',
      'pizza':'Pizza','burger':'Hambúrguer','curry':'Curry','stew':'Ensopado',
      'roast':'Assado','grilled':'Grelhado','bread':'Pão','rice':'Arroz',
      'potato':'Batata','egg':'Ovo','eggs':'Ovos','cheese':'Queijo','mushroom':'Cogumelo',
      'pancake':'Panqueca','pudding':'Pudim','steak':'Bife','meatballs':'Almôndegas',
      'shrimp':'Camarão','chocolate':'Chocolate','banana':'Banana','mango':'Manga',
    };
    String result = name;
    parts.forEach((en, pt) {
      result = result.replaceAll(RegExp(r'\b' + en + r'\b', caseSensitive: false), pt);
    });
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
    return result.isEmpty ? name : result;
  }

  static String translateIngredient(String ing) {
    final lower = ing.toLowerCase().trim();
    if (_ingredientTranslations.containsKey(lower)) return _ingredientTranslations[lower]!;
    for (final e in _ingredientTranslations.entries) {
      if (lower.contains(e.key)) return e.value;
    }
    return ing.isNotEmpty ? ing[0].toUpperCase() + ing.substring(1) : ing;
  }

  static String translateSearch(String query) {
    final lower = query.toLowerCase().trim();
    if (_ptToEn.containsKey(lower)) return _ptToEn[lower]!;
    for (final e in _ptToEn.entries) {
      if (lower.contains(e.key)) return e.value;
    }
    return query;
  }

  String translateCategory(String cat) => categoryTranslations[cat] ?? cat;
  String translateArea(String area) => areaTranslations[area] ?? area;

  // ── API calls ─────────────────────────────────────────────────────────────
  Future<List<Meal>> searchByName(String q) async {
    final r = await http.get(Uri.parse('$_base/search.php?s=$q'));
    return _parse(r);
  }

  Future<List<Meal>> searchByCategory(String c) async {
    final r = await http.get(Uri.parse('$_base/filter.php?c=$c'));
    return _parse(r);
  }

  Future<List<Meal>> searchByArea(String a) async {
    final r = await http.get(Uri.parse('$_base/filter.php?a=$a'));
    return _parse(r);
  }

  Future<List<Meal>> searchByIngredient(String i) async {
    final r = await http.get(Uri.parse('$_base/filter.php?i=$i'));
    return _parse(r);
  }

  Future<Map<String, dynamic>?> getRawMealById(String id) async {
    final r = await http.get(Uri.parse('$_base/lookup.php?i=$id'));
    if (r.statusCode == 200) {
      final d = json.decode(r.body);
      return d['meals'] != null ? d['meals'][0] : null;
    }
    return null;
  }

  Future<Meal?> getMealById(String id) async {
    final raw = await getRawMealById(id);
    return raw != null ? Meal.fromJson(raw) : null;
  }

  List<Map<String, String>> getIngredients(Map<String, dynamic> raw) {
    final list = <Map<String, String>>[];
    for (int i = 1; i <= 20; i++) {
      final ing  = raw['strIngredient$i']?.toString().trim() ?? '';
      final meas = raw['strMeasure$i']?.toString().trim() ?? '';
      if (ing.isNotEmpty) list.add({'ingredient': ing, 'measure': meas});
    }
    return list;
  }

  List<String> getSteps(String? instructions) {
    if (instructions == null || instructions.isEmpty) return [];
    final marker = RegExp(r'^(step|passo|etapa)\s*\d+\.?$', caseSensitive: false);
    return instructions
        .split(RegExp(r'\r\n|\n|\r'))
        .map((s) => s.trim())
        .where((s) => s.length > 10 && !marker.hasMatch(s))
        .toList();
  }

  Future<String> translateText(String text) async {
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx&sl=en&tl=pt&dt=t&q=${Uri.encodeComponent(text)}');
      final r = await http.get(url);
      final d = json.decode(r.body) as List;
      return (d[0] as List).map((item) => (item as List)[0].toString()).join('');
    } catch (_) { return text; }
  }

  List<Meal> _parse(http.Response r) {
    if (r.statusCode != 200) return [];
    final d = json.decode(r.body);
    if (d['meals'] == null) return [];
    return (d['meals'] as List).map((m) => Meal.fromJson(m)).toList();
  }
}

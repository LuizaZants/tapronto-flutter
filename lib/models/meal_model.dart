class Meal {
  final String id;
  final String name;
  final String thumb;
  final String? category;
  final String? area;
  final String? instructions;

  Meal({
    required this.id,
    required this.name,
    required this.thumb,
    this.category,
    this.area,
    this.instructions,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      thumb: json['strMealThumb'] ?? '',
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'],
    );
  }

  Map<String, dynamic> toMap() => {
    'idMeal': id,
    'strMeal': name,
    'strMealThumb': thumb,
    if (category != null) 'strCategory': category,
    if (area != null) 'strArea': area,
  };
}

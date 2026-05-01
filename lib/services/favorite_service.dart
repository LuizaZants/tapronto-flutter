import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_model.dart';

class FavoriteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = "favoritos";

  // Salva uma receita no Firebase
  Future<void> toggleFavorite(Meal meal) async {
    DocumentReference docRef = _db.collection(collection).doc(meal.id);

    var doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete(); // Remove se já for favorito
    } else {
      await docRef.set(meal.toMap()); // Adiciona se não for
    }
  }

  // Stream para ouvir os favoritos em tempo real
  Stream<List<Meal>> getFavorites() {
    return _db.collection(collection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Meal.fromJson(doc.data())).toList());
  }
}

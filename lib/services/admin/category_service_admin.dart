import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> addCategory(String name) async {
    String newCategoryId = DateTime.now().millisecondsSinceEpoch.toString();
    await _firebaseFirestore.collection('category').doc(newCategoryId).set({
      'ID': newCategoryId,
      'Name': name,
      'Messages': 0,
      'Inscriptions': 0,
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firebaseFirestore.collection('category').doc(categoryId).delete();
  }

  Stream<QuerySnapshot> getCategoriesStream() {
    return _firebaseFirestore.collection('category').snapshots();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CategoryService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Stream of categories from Firestore
  Stream<QuerySnapshot> getCategoryStream() {
    return _firebaseFirestore.collection('category').snapshots();
  }

  // Check if the user is subscribed to a specific category
  Future<bool> checkSubscription(String userEmail, String categoryName) async {
    final docId = '${userEmail}_$categoryName';
    DocumentSnapshot docSnapshot =
        await _firebaseFirestore.collection('inscription').doc(docId).get();
    return docSnapshot.exists;
  }

  // Toggle the subscription status of a user for a given category
  Future<void> toggleSubscription(
      String userEmail, String categoryName, bool isSubscribed) async {
    final docId = '${userEmail}_$categoryName';
    if (isSubscribed) {
      await unsubscribeUser(docId, categoryName);
    } else {
      await subscribeUser(userEmail, categoryName);
    }
  }

  // Unsubscribe the user from a category
  Future<void> unsubscribeUser(String docId, String categoryName) async {
    await _firebaseFirestore.collection('inscription').doc(docId).delete();
    await updateInscriptionCount(categoryName, -1);
    await _firebaseMessaging.unsubscribeFromTopic(categoryName);
    print('Unsubscribed from $categoryName');
  }

  // Subscribe the user to a category
  Future<void> subscribeUser(String userEmail, String categoryName) async {
    final docId = '${userEmail}_$categoryName';
    await _firebaseFirestore.collection('inscription').doc(docId).set({
      'user': userEmail,
      'category': categoryName,
    });
    await updateInscriptionCount(categoryName, 1);
    await _firebaseMessaging.subscribeToTopic(categoryName);
    print('Subscribed to $categoryName');
  }

  // Update the count of inscriptions for a category
  Future<void> updateInscriptionCount(String categoryName, int change) async {
    var categoryQuery = await _firebaseFirestore
        .collection('category')
        .where('Name', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (categoryQuery.docs.isNotEmpty) {
      DocumentReference categoryDocRef = categoryQuery.docs.first.reference;
      await categoryDocRef
          .update({'Inscriptions': FieldValue.increment(change)});
    } else {
      print('No category found with name $categoryName');
    }
  }
}

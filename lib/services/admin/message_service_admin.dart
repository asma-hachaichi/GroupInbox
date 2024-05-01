import 'package:cloud_firestore/cloud_firestore.dart';
import '../notification_service.dart';

class MessageService {
  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('message');
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection('category');

  Future<List<String>> fetchCategories() async {
    var categoriesSnapshot =
        await FirebaseFirestore.instance.collection('category').get();
    return categoriesSnapshot.docs
        .map((doc) => doc.data()['Name'] as String)
        .toList();
  }

  Future<void> deleteMessage(String id) async {
    DocumentSnapshot messageDoc = await messagesCollection.doc(id).get();
    if (messageDoc.exists) {
      String category = messageDoc.get('category');
      await messagesCollection.doc(id).delete();
      QuerySnapshot categoryQuery = await categoriesCollection
          .where('Name', isEqualTo: category)
          .limit(1)
          .get();
      if (categoryQuery.docs.isNotEmpty) {
        DocumentReference categoryDocRef = categoryQuery.docs.first.reference;
        categoryDocRef.update({'Messages': FieldValue.increment(-1)});
      }
    }
  }

  Future<void> updateMessage(
      String id, String category, String object, String body) async {
    await messagesCollection.doc(id).update({
      'category': category,
      'object': object,
      'body': body,
    });
  }

  Future<void> addMessage(String category, String object, String body) async {
    await messagesCollection.add({
      'category': category,
      'object': object,
      'body': body,
    });
    sendNotification(category, body);
    var querySnapshot = await categoriesCollection
        .where('Name', isEqualTo: category)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference categoryDocRef = querySnapshot.docs.first.reference;
      categoryDocRef.update({'Messages': FieldValue.increment(1)});
    }
  }
}

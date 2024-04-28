import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app_state.dart'; // This file should have your ApplicationState which contains the user's email.

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void _toggleSubscription(String categoryName, bool isSubscribed) async {
    final userEmail =
        Provider.of<ApplicationState>(context, listen: false).email;
    final docId = '${userEmail}_$categoryName';
    if (isSubscribed) {
      // Unsubscribe the user and decrement the inscriptions count
      await _firebaseFirestore.collection('inscription').doc(docId).delete();

      // Find the category document and decrement the inscriptions count
      var categoryQuery = await _firebaseFirestore
          .collection('category')
          .where('Name', isEqualTo: categoryName)
          .limit(1)
          .get();

      if (categoryQuery.docs.isNotEmpty) {
        DocumentReference categoryDocRef = categoryQuery.docs.first.reference;
        categoryDocRef.update({'Inscriptions': FieldValue.increment(-1)});
      }
    } else {
      // Subscribe the user and increment the inscriptions count
      await _firebaseFirestore.collection('inscription').doc(docId).set({
        'user': userEmail,
        'category': categoryName,
      });

      // Find the category document and increment the inscriptions count
      var categoryQuery = await _firebaseFirestore
          .collection('category')
          .where('Name', isEqualTo: categoryName)
          .limit(1)
          .get();

      if (categoryQuery.docs.isNotEmpty) {
        DocumentReference categoryDocRef = categoryQuery.docs.first.reference;
        categoryDocRef.update({'Inscriptions': FieldValue.increment(1)});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<ApplicationState>(context).email;

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                title: Text('Categories'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Messages'),
                onTap: () {
                  context.go('/messages');
                },
              ),
              ListTile(
                title: Text('Logout'),
                leading: Icon(Icons.logout),
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseFirestore.collection('category').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Text('Erreur lors du chargement des données');
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          final List<DocumentSnapshot> categories = snapshot.data!.docs;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = category['Name'];

              return FutureBuilder<DocumentSnapshot>(
                future: _firebaseFirestore
                    .collection('inscription')
                    .doc('${userEmail}_$categoryName')
                    .get(),
                builder: (context, subscriptionSnapshot) {
                  if (subscriptionSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      title: Text(categoryName),
                      trailing: CircularProgressIndicator(),
                    );
                  }
                  final isSubscribed =
                      subscriptionSnapshot.data?.exists ?? false;
                  return Card(
                    child: ListTile(
                      title: Text(categoryName),
                      trailing: ElevatedButton(
                        onPressed: () =>
                            _toggleSubscription(categoryName, isSubscribed),
                        child: Text(isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isSubscribed ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

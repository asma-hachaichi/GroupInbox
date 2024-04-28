import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryPageAdmin extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPageAdmin> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void _addCategory(String name) {
    String newCategoryId = DateTime.now().millisecondsSinceEpoch.toString();
    _firebaseFirestore.collection('category').doc(newCategoryId).set({
      'ID': newCategoryId,
      'Name': name,
    });
  }

  void _showAddMessageForm(String categoryName) {
    TextEditingController objectController = TextEditingController();
    TextEditingController bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un nouveau message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Catégorie: $categoryName',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: objectController,
                decoration: InputDecoration(labelText: 'Objet du message'),
              ),
              TextField(
                controller: bodyController,
                decoration: InputDecoration(labelText: 'Corps du message'),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () async {
                DocumentReference newMessageRef =
                    _firebaseFirestore.collection('message').doc();

                await newMessageRef.set({
                  'category': categoryName,
                  'object': objectController.text,
                  'body': bodyController.text,
                });

                // Query for the category document where "Name" equals categoryName
                var querySnapshot = await _firebaseFirestore
                    .collection('category')
                    .where('Name', isEqualTo: categoryName)
                    .limit(1)
                    .get();

                // Check if the query found at least one document
                if (querySnapshot.docs.isNotEmpty) {
                  // Get the reference to the first document found
                  DocumentReference categoryDocRef =
                      querySnapshot.docs.first.reference;

                  // Increment the message count atomically
                  categoryDocRef.update({'Messages': FieldValue.increment(1)});
                } else {
                  print('No category found with name $categoryName');
                }

                // Close the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(String categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette catégorie?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _firebaseFirestore
                    .collection('category')
                    .doc(categoryId)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryForm() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une nouvelle catégorie'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nom de la catégorie'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                _addCategory(nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catégories'),
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
                  context.go('/messages/admin');
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
          if (snapshot.hasError) {
            return Text('Erreur lors du chargement des données');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var category = documents[index].data() as Map<String, dynamic>;
              String categoryName = category['Name'];
              int messageCount = category['Messages'];
              int inscriptionCount = category['Inscriptions'];

              return Card(
                child: ListTile(
                  title: Text('Catégorie: $categoryName'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Inscriptions: $inscriptionCount'),
                      Text('Messages: $messageCount'),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Add Message'),
                            onPressed: () => _showAddMessageForm(categoryName),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            child: Text('Delete Category'),
                            onPressed: () =>
                                _deleteCategory(documents[index].id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryForm,
        tooltip: 'Ajouter Catégorie',
        child: Icon(Icons.add),
      ),
    );
  }
}

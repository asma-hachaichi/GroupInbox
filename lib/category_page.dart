import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void _addCategory(String name) {
    String newCategoryId = DateTime.now().millisecondsSinceEpoch.toString();
    _firebaseFirestore.collection('category').doc(newCategoryId).set({
      'ID': newCategoryId,
      'Name': name,
    });
  }

  Future<int> _getMessageCount(String categoryName) async {
    var querySnapshot = await _firebaseFirestore
        .collection('message')
        .where('category', isEqualTo: categoryName)
        .get();
    return querySnapshot.docs.length;
  }

  Future<int> _getInscriptionCount(String categoryName) async {
    var querySnapshot = await _firebaseFirestore
        .collection('inscription')
        .where('category', isEqualTo: categoryName)
        .get();
    return querySnapshot.docs.length;
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
              onPressed: () {
                _firebaseFirestore.collection('message').add({
                  'category': categoryName,
                  'object': objectController.text,
                  'body': bodyController.text,
                });
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

              return FutureBuilder<List<int>>(
                future: Future.wait([
                  _getMessageCount(categoryName),
                  _getInscriptionCount(categoryName),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Erreur lors du chargement des données');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  var counts = snapshot.data!;
                  int messageCount = counts[0];
                  int inscriptionCount = counts[1];
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
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Add Message'),
                                onPressed: () =>
                                    _showAddMessageForm(categoryName),
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

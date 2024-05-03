import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gtk_flutter/services/admin/category_service_admin.dart';
import 'package:gtk_flutter/services/admin/message_service_admin.dart';

class CategoryPageAdmin extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPageAdmin> {
  final CategoryService _categoryService = CategoryService();
  final MessageService _messageService = MessageService();

  void _showAddMessageForm(String categoryName) {
    TextEditingController objectController = TextEditingController();
    TextEditingController bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a new message to $categoryName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Category: $categoryName',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: objectController,
                decoration: InputDecoration(labelText: 'Object'),
              ),
              TextField(
                controller: bodyController,
                decoration: InputDecoration(labelText: 'Body'),
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
                _messageService.addMessage(
                    categoryName, objectController.text, bodyController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryForm(String categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this category?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _categoryService.deleteCategory(categoryId);
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
          title: Text('Add new category'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _categoryService.addCategory(nameController.text);
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
      appBar: AppBar(title: Text('Categories')),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                  title: Text('Categories'),
                  onTap: () => Navigator.pop(context)),
              ListTile(
                  title: Text('Messages'),
                  onTap: () => context.go('/messages/admin')),
              ListTile(
                  title: Text('Logout'),
                  leading: Icon(Icons.logout),
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () => context.go('/')),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _categoryService.getCategoriesStream(),
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
                  title: Text('Categorie: $categoryName'),
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
                                _showDeleteCategoryForm(documents[index].id),
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
        tooltip: 'Add Category',
        child: Icon(Icons.add),
      ),
    );
  }
}

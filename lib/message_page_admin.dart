import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class MessagePageAdmin extends StatefulWidget {
  @override
  MessagePageState createState() => MessagePageState();
}

class MessagePageState extends State<MessagePageAdmin> {
  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('message');
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection('category');

  List<String> categoryNames = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    var categoriesSnapshot =
        await FirebaseFirestore.instance.collection('category').get();
    setState(() {
      categoryNames = categoriesSnapshot.docs
          .map((doc) => doc.data()['Name'] as String)
          .toList();
      if (categoryNames.isNotEmpty) {
        selectedCategory = categoryNames.first;
      }
    });
  }

  // Method to delete a message from Firestore
  void _deleteMessage(String id) async {
    // First, get the message document by its ID to find out the category it belongs to
    DocumentSnapshot messageDoc = await messagesCollection.doc(id).get();
    if (messageDoc.exists) {
      String category = messageDoc.get('category');

      // Delete the message
      await messagesCollection.doc(id).delete();

      // Query the category document by the category name to get its reference
      QuerySnapshot categoryQuery = await categoriesCollection
          .where('Name', isEqualTo: category)
          .limit(1)
          .get();

      // Check if the category document exists
      if (categoryQuery.docs.isNotEmpty) {
        DocumentReference categoryDocRef = categoryQuery.docs.first.reference;

        // Atomically decrement the 'messages' count for the category
        categoryDocRef.update({'Messages': FieldValue.increment(-1)});
      } else {
        print('No category found with the name $category');
      }
    } else {
      print('Message with ID $id does not exist');
    }
  }

  // Method to show a dialog confirming deletion of a message
  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteMessage(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to show a form to edit a message
  void _showEditForm(Map<String, dynamic> messageData) {
    TextEditingController categoryController =
        TextEditingController(text: messageData['category']);
    TextEditingController objectController =
        TextEditingController(text: messageData['object']);
    TextEditingController bodyController =
        TextEditingController(text: messageData['body']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  enabled: false,
                ),
                TextField(
                  controller: objectController,
                  decoration: InputDecoration(labelText: 'Object'),
                ),
                TextField(
                  controller: bodyController,
                  decoration: InputDecoration(labelText: 'Body'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                messagesCollection.doc(messageData['id']).update({
                  'category': categoryController.text,
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

  // Méthode pour ajouter un nouveau message à Firestore
  void _addMessage(String category, String object, String body) async {
    // Add a new message to the 'message' collection
    await messagesCollection.add({
      'category': category,
      'object': object,
      'body': body,
    });

    // Query for the category document with the name equal to 'category'
    var querySnapshot = await categoriesCollection
        .where('Name', isEqualTo: category)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // Get the reference to the first document found
      DocumentReference categoryDocRef = querySnapshot.docs.first.reference;
      categoryDocRef.update({'messages': FieldValue.increment(1)});
    } else {
      print('No category found with the name $category');
    }
  }

  // Méthode pour afficher le formulaire d'ajout de message
  void _showAddMessageForm() {
    // The category controller is no longer needed because we're using a dropdown
    TextEditingController objectController = TextEditingController();
    TextEditingController bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nouveau Message'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  items: categoryNames
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10), // Added for spacing
                TextField(
                  controller: objectController,
                  decoration: InputDecoration(labelText: 'Object'),
                ),
                TextField(
                  controller: bodyController,
                  decoration: InputDecoration(
                      labelText: 'Body', border: OutlineInputBorder()),
                  keyboardType: TextInputType.multiline,
                  maxLines:
                      null, // Allows the input field to expand indefinitely.
                  minLines: 5, // Initial number of lines for the message field.
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (selectedCategory != null) {
                  _addMessage(
                    selectedCategory!,
                    objectController.text,
                    bodyController.text,
                  );
                  Navigator.of(context).pop();
                }
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
        title: Text('Messages'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                title: Text('Categories'),
                onTap: () {
                  context.go('/categories/admin');
                },
              ),
              ListTile(
                title: Text('Messages'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Logout'),
                leading: Icon(Icons.logout),
                textColor: Colors.red,
                onTap: () {
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMessageForm,
        child: Icon(Icons.add),
        tooltip: 'Nouveau Message',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: messagesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView(
            children: documents.map((doc) {
              Map<String, dynamic> message = doc.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(message['object']),
                  subtitle: Column(children: [
                    Text('Category : ' + message['category']),
                    Text(message['body']),
                  ]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.orange,
                        onPressed: () => _showEditForm({
                          'id': doc.id, // Include the document ID for reference
                          ...message,
                        }),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () => _showDeleteConfirmation(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

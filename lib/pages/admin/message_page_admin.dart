import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtk_flutter/services/admin/message_service_admin.dart';

class MessagePageAdmin extends StatefulWidget {
  @override
  MessagePageState createState() => MessagePageState();
}

class MessagePageState extends State<MessagePageAdmin> {
  final MessageService _messageService = MessageService();
  List<String> categoryNames = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    categoryNames = await _messageService.fetchCategories();
    setState(() {
      if (categoryNames.isNotEmpty) {
        selectedCategory = categoryNames.first;
      }
    });
  }

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
                _messageService.deleteMessage(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
                _messageService.updateMessage(
                    messageData['id'],
                    categoryController.text,
                    objectController.text,
                    bodyController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddMessageForm() {
    TextEditingController objectController = TextEditingController();
    TextEditingController bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Message'),
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
                  _messageService.addMessage(selectedCategory!,
                      objectController.text, bodyController.text);
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMessageForm,
        child: Icon(Icons.add),
        tooltip: 'New Message',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _messageService.messagesCollection.snapshots(),
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
                    Text('Category: ' + message['category']),
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

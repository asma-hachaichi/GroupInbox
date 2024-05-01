import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gtk_flutter/services/user/message_service.dart';

class MessagePage extends StatefulWidget {
  @override
  MessagePageState createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage> {
  Set<String> subscribedCategories = {};
  late final MessageService messageService;

  @override
  void initState() {
    super.initState();
    messageService = MessageService(context);
    _fetchSubscribedCategories();
  }

  void _fetchSubscribedCategories() async {
    subscribedCategories = await messageService.fetchSubscribedCategories();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Messages'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                title: Text('Categories'),
                onTap: () {
                  context.go('/categories');
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
      body: subscribedCategories.isEmpty
          ? Center(child: Text('No subscriptions found.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('message')
                  .where('category', whereIn: subscribedCategories.toList())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final documents = snapshot.data?.docs ?? [];
                return ListView(
                  children: documents.map((doc) {
                    Map<String, dynamic> message =
                        doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(message['object'] ?? 'No Subject'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category: ${message['category']}'),
                            Text(message['body'] ?? 'No Content'),
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

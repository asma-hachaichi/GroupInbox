import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app_state.dart'; // Make sure this contains the ApplicationState with the user's email

class MessagePage extends StatefulWidget {
  @override
  MessagePageState createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage> {
  Set<String> subscribedCategories = {};

  @override
  void initState() {
    super.initState();
    _fetchSubscribedCategories();
  }

  void _fetchSubscribedCategories() async {
    final userEmail =
        Provider.of<ApplicationState>(context, listen: false).email;
    var subscriptionsSnapshot = await FirebaseFirestore.instance
        .collection('inscription')
        .where('user', isEqualTo: userEmail)
        .get();

    setState(() {
      subscribedCategories = subscriptionsSnapshot.docs
          .map((doc) => doc.data()['category'] as String)
          .toSet();
    });
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

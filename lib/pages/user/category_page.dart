import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtk_flutter/services/user/category_service.dart';
import 'package:provider/provider.dart';
import 'package:gtk_flutter/app_state.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  CategoryService _categoryService = CategoryService(); // Service instance

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<ApplicationState>(context).email;

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
                  onTap: () => context.go('/messages')),
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
        stream: _categoryService.getCategoryStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error loading data');
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          final List<DocumentSnapshot> categories = snapshot.data!.docs;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = category['Name'];

              return FutureBuilder<bool>(
                future:
                    _categoryService.checkSubscription(userEmail, categoryName),
                builder: (context, subscriptionSnapshot) {
                  if (subscriptionSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                        title: Text(categoryName),
                        trailing: CircularProgressIndicator());
                  }
                  final isSubscribed = subscriptionSnapshot.data ?? false;
                  return Card(
                    child: ListTile(
                      title: Text(categoryName),
                      trailing: ElevatedButton(
                        onPressed: () => _categoryService.toggleSubscription(
                            userEmail, categoryName, isSubscribed),
                        child: Text(isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSubscribed ? Colors.red : Colors.green),
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

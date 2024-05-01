import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gtk_flutter/app_state.dart';

class MessageService {
  final BuildContext context;
  MessageService(this.context);

  Future<Set<String>> fetchSubscribedCategories() async {
    final userEmail =
        Provider.of<ApplicationState>(context, listen: false).email;
    var subscriptionsSnapshot = await FirebaseFirestore.instance
        .collection('inscription')
        .where('user', isEqualTo: userEmail)
        .get();

    return subscriptionsSnapshot.docs
        .map((doc) => doc.data()['category'] as String)
        .toSet();
  }
}

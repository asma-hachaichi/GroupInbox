import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendNotification(String category, String messagePreview) async {
  final String serverKey =
      'AAAACOEWIrA:APA91bHMtu_Vq74hj4i1I9mehjo6B7DEAlYtxtMM0z6gxRjcCr58gFGzCbLpWQh2Ix5D2CiEpdedr6IK2rDFvc-iXFDcNDcfjuAQdVAG4V7Bn2hHGYxqiOqIdJ8B_ucYH4r1i5gDalPt'; // Replace with your actual server key
  final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
  final String topic = category;

  final Map<String, dynamic> notificationPayload = {
    'notification': {
      'title': 'New message in $category',
      'body': messagePreview.length > 100
          ? '${messagePreview.substring(0, 100)}...'
          : messagePreview,
    },
    'priority': 'high',
    'to': '/topics/$topic',
  };

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverKey',
  };

  try {
    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: headers,
      body: jsonEncode(notificationPayload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully to $topic');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}

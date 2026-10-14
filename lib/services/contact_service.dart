import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact.dart';

class ContactService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com/users';

  Future<List<Contact>> getContacts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Contact.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load contacts. Status code: ${response.statusCode}');
    }
  }

  // دالة إضافة جهة اتصال جديدة باستخدام طلب POST
  Future<Contact> addContact(Contact contact) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(contact.toJson()),
    );

    // فحص كود الحالة 201 (Created)
    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Contact.fromJson(data);
    } else {
      throw Exception('Failed to add contact. Status code: ${response.statusCode}');
    }
  }
}

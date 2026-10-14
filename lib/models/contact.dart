class Contact {
  final int id;
  final String name;
  final String email;
  final String phone;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  // Factory constructor to create a Contact instance from JSON map
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  // Method to convert Contact instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

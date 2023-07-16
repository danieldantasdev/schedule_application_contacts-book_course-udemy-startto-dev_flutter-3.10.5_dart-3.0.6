class Contact {
  int? id;
  String name;
  String email;
  String phone;
  String image;

  Contact({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
    );
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, email: $email, phone: $phone, image: $image}';
  }
}

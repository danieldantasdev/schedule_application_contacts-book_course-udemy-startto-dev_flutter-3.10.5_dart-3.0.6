import 'package:flutter/material.dart';
import 'package:schedule/repositories/contact.repository.dart';

import '../models/models.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContactRepository _contactRepository = ContactRepository();

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
    Contact contact = Contact(
      name: "John Doe",
      email: "johndoe@example.com",
      phone: "1234567890",
      image: "profile.png",
    );

    _contactRepository.save(contact).then((value) => print(value));
    _contactRepository.getAll().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Icon(
          Icons.schedule,
          size: 50,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:schedule/enums/enums.dart';
import 'package:schedule/pages/create_or_update.page.dart';
import 'package:schedule/repositories/contact.repository.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContactRepository _contactRepository = ContactRepository();
  List<Contact> _contacts = [];

  Widget _itemBuilder(BuildContext buildContext, int index) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _contacts[index].image.isNotEmpty
                          ? FileImage(File(_contacts[index].image))
                              as ImageProvider
                          : const AssetImage("assets/person.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contacts[index].name ?? "",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _contacts[index].email ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _contacts[index].phone ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
      onTap: () => _showOption(context, index),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void _showOption(BuildContext buildContext, int index) {
    showModalBottomSheet(
      context: buildContext,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(10.00),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _makePhoneCall(_contacts[index].phone);
                      Navigator.pop(context);
                    },
                    child: const Text("Ligar"),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showContactPage(contact: _contacts[index]);
                    },
                    child: const Text("Editar"),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _contactRepository.delete(_contacts[index].id);
                        _contacts.removeAt(index);
                        Navigator.pop(context);
                      });
                    },
                    child: const Text("Excluir"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showContactPage({Contact? contact}) async {
    final reqContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrUpdatePage(contact: contact),
      ),
    );

    if (reqContact != null) {
      if (contact != null) {
        reqContact.id = contact.id;
        await _contactRepository.update(reqContact.id, reqContact);
      } else {
        await _contactRepository.save(reqContact);
      }
      _getAll();
    }
  }

  void _getAll() {
    _contactRepository.getAll().then(
      (value) {
        setState(() {
          _contacts = value;
        });
        print(value);
      },
    );
  }

  void _onSelected(Order order) {
    switch (order) {
      case Order.az:
        _contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case Order.za:
        _contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('contatos'),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Order>(
            itemBuilder: (context) => <PopupMenuEntry<Order>>[
              const PopupMenuItem<Order>(
                child: Text("Ordem crescente"),
                value: Order.az,
              ),
              const PopupMenuItem<Order>(
                child: Text("Ordem decrescente"),
                value: Order.za,
              )
            ],
            onSelected: _onSelected,
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          return _itemBuilder(context, index);
        },
        itemCount: _contacts.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage(contact: null);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}

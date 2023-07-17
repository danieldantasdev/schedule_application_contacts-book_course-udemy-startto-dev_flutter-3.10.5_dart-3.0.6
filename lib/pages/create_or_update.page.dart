import 'dart:io';

import 'package:flutter/material.dart';

import '../models/models.dart';

class CreateOrUpdatePage extends StatefulWidget {
  const CreateOrUpdatePage({Key? key, this.contact}) : super(key: key);

  final Contact? contact;

  @override
  State<CreateOrUpdatePage> createState() => _CreateOrUpdatePageState();
}

class _CreateOrUpdatePageState extends State<CreateOrUpdatePage> {
  late Contact _editContact;
  bool _userEdited = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _focusNodeName = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact != null) {
      _editContact = Contact.fromJson(widget.contact!.toJson());
      _nameController.text = _editContact.name ?? '';
      _emailController.text = _editContact.email ?? '';
      _phoneController.text = _editContact.phone ?? '';
    } else {
      _editContact = Contact(name: '', email: '', phone: '', image: '');
    }
  }

  Future<bool> _onWillPop() async {
    if (_userEdited) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Descartar alterações"),
            content: const Text("Suas alterações serão perdidas"),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Sair"),
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(_editContact.name.isNotEmpty
              ? _editContact.name!
              : 'Novo Contato'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editContact.image.isNotEmpty
                          ? FileImage(File(_editContact.image!))
                              as ImageProvider
                          : const AssetImage("assets/person.png"),
                    ),
                  ),
                ),
              ),
              TextField(
                focusNode: _focusNodeName,
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nome",
                ),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editContact.name.isNotEmpty && _userEdited) {
              Navigator.pop(context, _editContact);
            } else {
              FocusScope.of(context).requestFocus(_focusNodeName);
            }
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(
            Icons.save,
          ),
        ),
      ),
    );
  }
}

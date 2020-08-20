import 'dart:io';

import 'package:agenda_de_contatos/models/contact.model.dart';
import 'package:agenda_de_contatos/pages/contact.page.dart';
import 'package:agenda_de_contatos/services/contact.service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactService contactService = ContactService();

  List<Contact> contactList = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  void _getAllContacts() {
    contactService.getAllContacts().then((list) {
      setState(() {
        contactList = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) =>
            <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _showContactPage,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemBuilder: contactCard,
        itemCount: contactList.length,
        padding: EdgeInsets.all(10),
      ),
    );
  }

  Widget contactCard(context, index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              // Cria uma imagem redonda
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contactList[index].img != null
                        ? FileImage(File(contactList[index].img))
                        : AssetImage("assets/person.png"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contactList[index].name ?? "",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contactList[index].email ?? "",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      contactList[index].phone ?? "",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Ligar",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () {
                          launch("tel:${contactList[index].phone}");
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Editar",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: contactList[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Excluir",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () {
                          contactService.deleteContact(contactList[index].id);
                          setState(() {
                            contactList.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ContactPage(
              contact: contact,
            ),
      ),
    );
    if (recContact != null) {
      if (contact != null) {
        await contactService.updateContact(recContact);
      } else {
        await contactService.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contactList.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contactList.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}

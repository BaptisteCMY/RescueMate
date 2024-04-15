import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contact extends StatefulWidget {
  const Contact({Key? key}) : super(key: key);

  static List<String> contacts = [];

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _contactController = TextEditingController();

    // Récupérez les préférences partagées
    SharedPreferences.getInstance().then((prefs) {
      List<String>? savedContacts = prefs.getStringList('contacts');
      if (savedContacts != null) {
        setState(() {
          Contact.contacts = savedContacts;
        });
      }
    });
  }

  @override
  void dispose() {
    _saveContactsToPreferences();
    _contactController.dispose();
    super.dispose();
  }

  void _saveContactsToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('contacts', Contact.contacts);
  }


  void _saveContact(BuildContext context) async {
    String contactNumber = _contactController.text;

    // Récupérez les préférences partagées
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ajoutez le contact à la liste des contacts dans les préférences partagées
    List<String>? contacts = prefs.getStringList('contacts');
    if (contacts == null) {
      contacts = [];
    }
    contacts.add(contactNumber);
    await prefs.setStringList('contacts', contacts);

    // Mise à jour de la liste des contacts statiques après l'ajout
    setState(() {
      Contact.contacts = contacts ?? [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact sauvegardé: $contactNumber'),
        duration: Duration(seconds: 2),
      ),
    );

    _contactController.clear();
  }


  void _removeContact(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? contacts = prefs.getStringList('contacts');
    if (contacts != null) {
      contacts.removeAt(index);
      await prefs.setStringList('contacts', contacts);
      setState(() {
        Contact.contacts = contacts; // Mettre à jour la liste des contacts statiques
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector( // Utilisez GestureDetector pour détecter les clics sur l'icône de l'application
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomePage(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/img/logoRM.png",
              width: 30,
              height: 30,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'RescueMate',
          style: TextStyle(fontSize: 28, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Entrez le numéro de téléphone du contact',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveContact(context),
              child: const Text('Enregistrer le contact'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: Contact.contacts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(Contact.contacts[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeContact(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

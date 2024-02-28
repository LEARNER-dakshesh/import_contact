import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:import_contact/Contacts.dart'; // Import the file where Contacts box is defined

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  List<FavoriteContact> favoriteContacts = []; // List to hold favorite contacts

  @override
  void initState() {
    super.initState();
    retrieveContacts(); // Retrieve contacts when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Contacts'),
      ),
      body: ListView.builder(
        itemCount: favoriteContacts.length,
        itemBuilder: (context, index) {
          FavoriteContact contact = favoriteContacts[index];
          return ListTile(
            title: Text(contact.name),
            subtitle: Text(contact.phoneNumber),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Call a method to delete the contact from Hive database
                deleteContact(contact.name);
              },
            ),
          );
        },
      ),
    );
  }

  void retrieveContacts() async {
    // Open the Hive box
    final contactsBox = await Hive.openBox('favorites');

    // Retrieve the list from the box
    List<FavoriteContact> favoriteContacts = [];
    for (var value in contactsBox.values) {
      if (value is Map<String, dynamic>) { // Ensure the value is a Map<String, dynamic>
        FavoriteContact contact = FavoriteContact.fromJson(value);
        favoriteContacts.add(contact);
      } else if (value is Map<dynamic, dynamic>) { // Handle the alternate map type
        // Convert the dynamic map to Map<String, dynamic> if possible
        Map<String, dynamic> typedMap = value.cast<String, dynamic>();
        FavoriteContact contact = FavoriteContact.fromJson(typedMap);
        favoriteContacts.add(contact);
      } else {
        print('Encountered unexpected data type: ${value.runtimeType}');
        // Handle unexpected data type, if needed
      }
    }

    setState(() {
      this.favoriteContacts = favoriteContacts;
    });
  }
  void deleteContact(String contactName) async {
    final contactsBox = await Hive.openBox('favorites');

    // Find the contact with the matching name
    final contactKey = contactsBox.keys.firstWhere((key) => contactsBox.get(key)['name'] == contactName);

    if (contactKey != null) {
      // Delete the contact from the box
      await contactsBox.delete(contactKey);
      final snackBar=SnackBar(content: Text("Deleting.....Reopen the page"),backgroundColor: Colors.red,);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        retrieveContacts();
        // Retrieve the updated list of contacts
      });
    } else {
      // Handle the case where the contact is not found
      print('Contact not found: $contactName');
    }
    await contactsBox.close();
  }
}

class AnotherClass {
  void retrieveContacts() async {
    // Open the Hive box
    final contactsBox = await Hive.openBox('favorites');

    // Retrieve the list from the box
    List<FavoriteContact> favoriteContacts = contactsBox.values.toList().cast<FavoriteContact>();

    // Now you can use favoriteContacts list in this class
    // For example, print each contact's name and phone number
    favoriteContacts.forEach((contact) {
      print('Name: ${contact.name}, Phone: ${contact.phoneNumber}');
    });
    contactsBox.close();
  }
}

class FavoriteContact {
  String name;
  String phoneNumber;

  FavoriteContact({required this.name, required this.phoneNumber});

  factory FavoriteContact.fromJson(Map<String, dynamic> json) {
    return FavoriteContact(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

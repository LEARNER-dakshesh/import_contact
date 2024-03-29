import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:import_contact/Favorites.dart';
import 'package:import_contact/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velocity_x/velocity_x.dart';

class Contacts extends StatefulWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  TextEditingController _searchController = TextEditingController();
  late List<Contact> _contacts = [];
  late List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  void _filterContacts(String query) {
    List<Contact> filteredList = _contacts.where((contact) {
      return contact.displayName.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      _filteredContacts = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        centerTitle: true,
        backgroundColor: AColors.primaryColor1,
      ),
      body: Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search for a contact...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _filterContacts(value);
              },
            ),
          ),
          // SizedBox(
          //   height: 50,
          // ),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('favorites').listenable(),
              builder: (content, box, child) {
                return FutureBuilder<List<Contact>>(
                  future: getContacts(),
                  builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error}"),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text("No contacts available"),
                      );
                    } else {
                      _contacts = snapshot.data!;
                      return ListView.builder(
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          Contact contact = _filteredContacts[index];
                          return ListTile(
                            onTap: () {
                              // Toggle selection on tap
                            },
                            onLongPress: () {
                              // Add contact to selected list on long press
                            },
                            leading: const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.person),
                            ),
                            title: Text(contact.displayName),
                            trailing: IconButton(
                              onPressed: () async {
                                FavoriteContact favoriteContact = FavoriteContact(
                                  name: contact.displayName,
                                  phoneNumber: contact.phones.isNotEmpty ? contact.phones[0].number : "",
                                );

                                final box = Hive.box('favorites');
                                final existingNames = box.values.map((e) => e['name'] as String).toSet(); // Get existing names as a Set

                                if (!existingNames.contains(favoriteContact.name)) { // Check if name already exists
                                  box.add(favoriteContact.toJson());
                                  final snackbar = SnackBar(
                                    content: Text("Added Successfully"),
                                    backgroundColor: Colors.blue,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                } else {
                                  final snackbar = SnackBar(
                                    content: Text("Contact is already a favorite"),
                                    backgroundColor: Colors.red,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                }
                              },
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(contact.phones.isNotEmpty
                                    ? contact.phones[0].number
                                    : "No phone number"),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
         // Button :Text("Favorites Contacts ") onpressed :Favorite();
        ],
      ),
    );
  }

  Future<List<Contact>> getContacts() async {
    bool isGranted = await Permission.contacts.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.contacts.request().isGranted;
    }
    if (isGranted) {
      return await FastContacts.getAllContacts();
    } else {
      throw Exception("Permission denied for accessing contacts");
    }
  }
}

class FavoriteContact {
  final String name;
  final String phoneNumber;

  FavoriteContact({required this.name, required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }
  factory FavoriteContact.fromJson(Map<String, dynamic> json) {
    return FavoriteContact(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

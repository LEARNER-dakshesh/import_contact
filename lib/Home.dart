import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:import_contact/contacts.dart';
import 'package:telephony_sms/telephony_sms.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:import_contact/utils/colors.dart';
import 'package:import_contact/utils/colors.dart'; // Import geolocator package
import 'package:hive/hive.dart';
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(LinearGradient(
            colors: [AColors.primaryColor1, AColors.primaryColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ))
              .make(),
          AppBar(
            title: "Shakti"
                .text
                .bold
                .white
                .make()
                .shimmer(primaryColor: AColors.primaryColor2),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () async {
                  try {
                    await _shareLocationWithFavorites();
                    // print("Successfully shared location with favorites");
                  } catch (e) {
                    print("Error sharing location: $e");
                  }
                },
                icon: Icon(Icons.location_on, color: Colors.black, size: 30),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Contacts()));
                },
                icon: Icon(Icons.account_box_outlined,
                    color: Colors.black, size: 30),
              ),
            ],
          ).h(100).px16(),
        ],
      ),
    );
  }

  Future<void> _shareLocationWithFavorites() async {
    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Open the Hive box
      final contactsBox = await Hive.openBox('favorites');
      // print("Hive box 'favorites' opened successfully.");
      // Iterate through favorite contacts
      // print('Number of values in contactsBox: ${contactsBox.values.length}');

      for (var value in contactsBox.values) {
        print('fetching ...');
        print('Value is a ${value.runtimeType}: $value');

        print("trying to enter, ${value.runtimeType}");
        if (value is Map<String, dynamic>|| value is Map<dynamic,dynamic>) {


          if (value is Map<String, dynamic>) {
            print("IN 1");
            print("I am in <String, dynamic>");
            print('Value is a map: $value');
            if (value.containsKey('name')) { // Ensure 'name' key exists
              print('Value contains key "name": ${value['name']}');
              FavoriteContact contact = FavoriteContact.fromJson(value);
              print('Favorite contact name: ${contact
                  .name}'); // Print contact name
              // Notify contact about shared location
              _notifyContact(contact, position.latitude, position.longitude);
            }
          }else if (value is Map<dynamic, dynamic>) {
            print("I am in <dynamic, dynamic>");
            Map<String, dynamic> typedMap = value.cast<String, dynamic>();
            FavoriteContact contact = FavoriteContact.fromJson(typedMap);
            print('Favorite contact name: ${contact.name}');
            _notifyContact(contact, position.latitude, position.longitude);
          }
          else {
            print("IN 3");
            print('Value does not contain key "name"');
          }
        }
        else {
          print('Value is not a map: $value');
        }
      }

      // Close the Hive box
      // await contactsBox.close();
    } catch (e) {
      print("Error sharing location: $e");
      // Handle error
    }
  }

  Future<void> _notifyContact(FavoriteContact contact, double latitude, double longitude) async {
    // Implement your logic to notify the contact about the shared location
    String phoneNumber = contact.phoneNumber;
    final _telephonySMS = TelephonySMS();
    await _telephonySMS.requestPermission();
    String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    String message1 = 'Emergency: My location is Latitude: $latitude ,Longitude : $longitude  Track me at : $googleMapsUrl';
    await _telephonySMS.sendSMS(
        phone: phoneNumber,
        message: message1);
  }
}
class FavoriteContact {
  String name;
  String phoneNumber;
  FavoriteContact({
    required this.name,
    required this.phoneNumber,
  });

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
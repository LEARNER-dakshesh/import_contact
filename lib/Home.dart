import 'package:flutter/material.dart';
import 'package:import_contact/contacts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:import_contact/utils/colors.dart';

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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Contacts()));
                  },
                  icon: Icon(Icons.account_box_outlined,
                      color: Colors.black, size: 30)),
            ],
          ).h(100).px16(),
        ],
      ),
    );
  }
}

// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:social_meadia/component/my_list_tiles.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;
  MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignOut,
    });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 64,
            ),
          ),

          MyListTile(
            icon: Icons.home, 
            text: 'H O M E', 
            onTap: () => Navigator.pop(context),
          ),
          MyListTile(
            icon: Icons.person, 
            text: 'P R O F I L E', 
            onTap: onProfileTap,
          ),
          ],
          ),

          Padding(
            padding:  EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout, 
              text: 'L O G O U T', 
              onTap: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
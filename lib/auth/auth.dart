// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_meadia/auth/login_or_register.dart';

import '../pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context , snapshot){
          if(snapshot.hasData){
            return HomePage();
          }
          else{
            return LoginOrRegister();  
          }
        },
      )
    );
  }
}
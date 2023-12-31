// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_meadia/component/text_field.dart';
import '../component/button.dart';


class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key , required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void signIn() async{
    showDialog(
      context: context,  
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      )
    );


    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      if(context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  void displayMessage(String message){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal : 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(
                Icons.lock,
                size: 100,
              ),
        
              Text("Welcome back , we missed you",
              style: TextStyle(color: Colors.grey[700]),
              ),
        
              SizedBox(height: 25,),

              MyTextField(
                controller: emailTextController,
                hintText: 'Email',
                obscureText: false,
              ),

              SizedBox(height: 25,),

              MyTextField(
                controller: passwordTextController,
                hintText: 'Password',
                obscureText: true,
              ),

              SizedBox(height: 25),

              Mybutton(
                onTap: signIn, 
                text: 'Sign In',
              ),
              
              SizedBox(height: 25,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Not a member?",
                  style: TextStyle(color: Colors.grey[700]),
                  ),

                  SizedBox(width: 4,),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Register now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
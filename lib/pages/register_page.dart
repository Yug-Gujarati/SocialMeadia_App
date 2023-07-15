// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/button.dart';
import '../component/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key , required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  void signUp() async {
    showDialog(
      context: context, 
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    if(passwordTextController.text != confirmPasswordTextController.text){
      Navigator.pop(context);
      displayMessage("Passwords don't match");
      return;
    }

    try{
      UserCredential userCredential = 
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email:emailTextController.text,
        password: passwordTextController.text,
      );

      FirebaseFirestore.instance
      .collection("Users")
      .doc(userCredential.user!.email!)
      .set({
        'username': emailTextController.text.split('@')[0],
        'bio': 'Empty Bio..'
      });

      if(context.mounted) Navigator.pop(context);
    }on FirebaseException catch (e) {

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
        
              SizedBox(height: 50,),
        
              Text("Let's create an account for you",
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

              SizedBox(height: 25,),

              MyTextField(
                controller: confirmPasswordTextController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              SizedBox(height: 25),

              Mybutton(
                onTap: signUp, 
                text: 'Sign up',
              ),
              
              SizedBox(height: 25,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?",
                  style: TextStyle(color: Colors.grey[700]),
                  ),

                  SizedBox(width: 4,),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Login here",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              )
            ]
          ),
        ),
      ),
    );
  }
}
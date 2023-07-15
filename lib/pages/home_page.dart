import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_meadia/component/drawer.dart';
import 'package:social_meadia/component/wall_post.dart';
import 'package:social_meadia/helper/helper_methodes.dart';

import '../component/text_field.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();

  void signOut(){
    FirebaseAuth.instance.signOut();
  }

  void postMessage(){
    if(textController.text.isNotEmpty){
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp':Timestamp.now(),
        'Likes': [],
      });
    }
    setState(() {
      textController.clear();
    });
  }

  void goToProfilePage(){
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('The Wall'),
        centerTitle: true,
     ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      body: Center(
        child: Column(
            children: [

              Expanded(
                child:StreamBuilder(
                  stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy(
                    "TimeStamp",
                    descending: false,
                  )
                  .snapshots(),
                  builder: (context,snapshot) {
                    if(snapshot.hasData){
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context,index){
                            final post = snapshot.data!.docs[index];
                            return WallPost(
                              message: post['Message'], 
                              user: post['UserEmail'],
                              postId: post.id,
                              likes: List<String>.from(post['Likes']?? []),
                              time: formatDate(post['TimeStamp']),
                          );
                        },
                      );
                    }else if(snapshot.hasError){
                      return Center(
                        child: Text('Error:${snapshot.error}'),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
             ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        controller: textController,
                        hintText: 'Write Message',
                        obscureText: false,
                      )
                  ),
                  IconButton(
                    onPressed: postMessage, 
                    icon: const Icon(Icons.arrow_circle_up)
                  ),
                ],
                          ),
              ),
              Text(
                "Logged in as:${currentUser.email!}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
        ),
      ),  
    );
  }
}
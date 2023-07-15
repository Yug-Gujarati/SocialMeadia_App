import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_meadia/component/comment_button.dart';
import 'package:social_meadia/component/delete_button.dart';
import 'package:social_meadia/helper/helper_methodes.dart';

import 'comment.dart';
import 'like_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final String time;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
    });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {

  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState(){
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }


  void toggleLike(){
    setState(() {
        isLiked = !isLiked;
    });
    DocumentReference postRef = 
      FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    
    if(isLiked){
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    }else{
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
    });
    }
  }


  void addComment(String commentText){
    FirebaseFirestore.instance
    .collection("User Posts")
    .doc(widget.postId)
    .collection("Comments")
    .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now(),
    });
  }

  void showCommentDialog(){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "Write a Comment.."),
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context);
            _commentTextController.clear();
            },
            child: const Text("Cancle"),
          ),

          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);
              Navigator.pop(context);
              _commentTextController.clear();
            } , 
            child: const Text("post"),
          ),  
        ],
      ),
    );
  }

  void deletePost(){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure, you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: ()=> Navigator.pop(context), 
            child: const Text("Cancle"),
          ),

          TextButton(
            onPressed: () async{
              final commentDocs = await FirebaseFirestore.instance
              .collection("User Posts")
              .doc(widget.postId)
              .collection("Comments")
              .get();

              for(var doc in commentDocs.docs){
                await FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .doc(doc.id)
                .delete();
              }
              
              FirebaseFirestore.instance
              .collection("User Posts")
              .doc(widget.postId)
              .delete()
              // ignore: avoid_print
              .then((value)=> print("Post deleted"))
              .catchError(
                // ignore: avoid_print
                (error) => print("failed to delete post: $error"));


              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            }, child: const Text("Delete"),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top:25,left: 25, right: 25),
      padding: const EdgeInsets.all(25),

      //posts
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(widget.message),
                  const SizedBox(height: 5,),
                  Row(
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    " . ",
                   style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(color: Colors.grey[400]),
                    ),
                ],
              )   
              ],
            ),
            if(widget.user == currentUser.email)
              DeleteButton(onTap: deletePost),
          ],
        ),

          const SizedBox(height: 20,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  LikeButton(
                    isLiked: isLiked, 
                    onTap:toggleLike,
                  ),

                  const SizedBox(height: 5,),
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(color: Colors.grey),
                      )
                ],
              ),

              const SizedBox(width: 10,),
              Column(
                children: [
                  CommentButton(onTap: showCommentDialog),

                  const SizedBox(height: 5,),
                  const Text(
                    '0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

        const SizedBox(height: 20,),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
            .collection("User Posts")
            .doc(widget.postId)
            .collection("Comments")
            .orderBy("CommentTime" , descending: true)
            .snapshots(),
            builder: (context , snapshot){
              if(!snapshot.hasData){
                return const Center(
                  child:CircularProgressIndicator(),
                );
              }
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc){
                  final commentData = doc.data() as Map<String , dynamic>;

                  return Comment(
                    text:commentData['CommentText'],
                    user:commentData['CommentedBy'],
                    time:formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            }
          ),
        ],
      ),
    );
  }
}
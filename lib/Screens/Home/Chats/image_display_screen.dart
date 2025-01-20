import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImagesDisplayScreen extends StatelessWidget {
  String chatId;
  String sender;
  String uploadId;
  ImagesDisplayScreen({super.key,required this.chatId,required this.sender,required this.uploadId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: StreamBuilder(stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').doc(sender+uploadId).snapshots(), builder: (context,snapshot){ 
          
          if(snapshot.hasData){
          return ListView.builder(
            itemCount: snapshot.data!.data()!['message'].length,
            itemBuilder: (context,index){
             return Column(
               children: [
                IconButton(onPressed: () async{
            for(int i=0;i<snapshot.data!.data()!['message'].toList().length;i++){
     
          final response = await http.get(Uri.parse(snapshot.data!.data()!['message'][i]));
          final fileBytes = await response.bodyBytes;
                final resultTime = DateTime.now().millisecondsSinceEpoch; 
          final saveResult = await SaverGallery.saveImage(fileBytes, fileName: 'baatchitImages/$resultTime.png', skipIfExists: false).then((data){
            if(data.isSuccess){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image successfully saved',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),backgroundColor: Colors.green,));
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sorry, image cannot be saved',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),backgroundColor: Colors.red,));
            }
          });
          
            }

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully downloaded image')));
           
          }, icon: Icon(Icons.download,color: Colors.blue,size:60,)),
                 Container(
                  
                  height: MediaQuery.of(context).size.height*0.4,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage('${snapshot.data!.data()!['message'][index]}'),fit: BoxFit.cover)
                  ),
                 ),
               ],
             );
          });
          }
          else{
            if(snapshot.hasError){
              return Text('${snapshot.error}',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18),);
            }
            else{
              return Center(child: CircularProgressIndicator(color: Colors.blue,),);
            }
          }
          })
 
      
    
    ));
  }
}
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageSendScreen extends StatelessWidget {
   List<File> imageFiles;
   String chatRoomId;
   String userProfile;

  ImageSendScreen({super.key,required this.imageFiles,required this.chatRoomId,required this.userProfile});

TextEditingController captionTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Column(
        children: [
          Expanded(flex: 3,child: ListView.builder(
            
            scrollDirection: Axis.horizontal,
            itemCount: imageFiles.length, itemBuilder: (context,index){
            return Container(
              height: MediaQuery.of(context).size.height*0.5,
              width:200,
            decoration: BoxDecoration(
              image: DecorationImage(image: FileImage(imageFiles[index]),fit: BoxFit.fill),
            ),
            );
          }),),
          Expanded(child:TextField(
            controller: captionTextController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              
              suffix: IconButton(onPressed: () async{
      
               
      
                String chatDate = DateTime.now().day.toString()+'/'+DateTime.now().month.toString()+'/'+DateTime.now().year.toString();
                String minuteFormat = DateTime.now().minute.toString().length<2?'0'+DateTime.now().minute.toString():DateTime.now().minute.toString();
                String hourFormat='';
                String meidianCode='';
                 
                 if(DateTime.now().hour==12 || DateTime.now().hour == 24){
                  switch(DateTime.now().hour){
                    case 12:{
                    hourFormat='12';
                    meidianCode='pm';
                    }
                    break;
                    case 24:
                    {
                    hourFormat='12';
                    meidianCode='am';
                    }
                    break;
                    
                  }
                 }
                 else{
                  if(DateTime.now().hour>12){
                    hourFormat=(DateTime.now().hour % 12).toString();
                    meidianCode='pm';
                  }
                  else{
                    hourFormat=(DateTime.now().hour % 12).toString();
                    meidianCode='am';
                  }
                 }
                List<String> mediaUrls=[];
                String chatTime = hourFormat.toString()+':'+minuteFormat+meidianCode;
                int chatUploadId = DateTime.now().millisecondsSinceEpoch;
      
                  for(int i=0;i<imageFiles.length;i++){
                     await FirebaseStorage.instance.ref().child('sendMedia/sendImages/${FirebaseAuth.instance.currentUser!.uid}${chatUploadId}$i').putFile(imageFiles[i]!);
                     String medias = await FirebaseStorage.instance.ref().child('sendMedia/sendImages/${FirebaseAuth.instance.currentUser!.uid}${chatUploadId}$i').getDownloadURL();
                    mediaUrls.add(medias);
                  }
                  
                 FirebaseFirestore.instance.collection('chats').doc(chatRoomId).collection('messages').doc(FirebaseAuth.instance.currentUser!.uid+chatUploadId.toString()).set({
                  'chatId':chatUploadId.toString(),
                  'message':mediaUrls,
                  'caption':captionTextController.text,
                  'isReply':false,
                   'isForward':false,
                   'replyFileName':'',
                    'replyToMessage':'',
                    'replyToChatType':'',
                    'replyToChatId':'',
                  'fileType':'image',
                  'fileName':'imageFile',
                  'mediaCount':mediaUrls.length,
                  'isImage':true,
                  'isForward':false,
                  'senderId':FirebaseAuth.instance.currentUser!.uid,
                  'chatUploadDate':chatDate,
                  'chatTime':chatTime,
                  'isRead':false,
                  'senderProfile':userProfile,
                  'reactions':[],
                 }).then((d){
                  captionTextController.clear();
                  Navigator.pop(context);
                 });
              }, icon:Icon(Icons.send,size: 35,)),
            ),
          ),flex: 1,)
        ],
      
      ),
    ));
  }
}
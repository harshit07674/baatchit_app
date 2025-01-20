import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:baatchit/Screens/Home/homescreen.dart';
import 'package:baatchit/Widgets/uihelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  String userName;
  String password;
  String phoneNumber;
  String phoneCode;
  ProfileScreen({required this.phoneCode, required this.userName,required this.password,required this.phoneNumber});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();

  File? pickedimage;
  String profileUrl='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            UiHelper.CustomText(
                text: "Profile info",
                height: 20,
                color: const Color(0XFF00A884),
                fontweight: FontWeight.bold),
            const SizedBox(
              height: 30,
            ),
            UiHelper.CustomText(
                text: "Please provide your name and an optional", height: 14),
            UiHelper.CustomText(text: "profile photo", height: 14),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: (){
                _openBottom(context);
              },
              child:pickedimage==null? CircleAvatar(
                radius: 80,
                backgroundColor: const Color(0XFFD9D9D9),
                child: Image.asset(
                  "assets/images/photo-camera 1.png",
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ):CircleAvatar(
                radius: 80,
                backgroundImage: FileImage(pickedimage!),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    keyboardType: TextInputType.name,
                    controller: nameController,
                    decoration: const InputDecoration(
                        hintText: "Type your Bio here",
                        hintStyle: TextStyle(color: Color(0XFF5E5E5E)),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF05AA82))),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF05AA82))),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFF05AA82)))),
                  ),
                ),
                const SizedBox(width: 10,),
                Image.asset("assets/images/happy-face 1.png")
              ],
            )
          ],
        ),
      ),
      floatingActionButton: UiHelper.CustomButton(callback: (){
        registerUser();
      }, buttonname: "Register"),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _openBottom(BuildContext context){
    return showModalBottomSheet(context: context, builder: (BuildContext context){
      return Container(
        height: 200,
        width: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: (){
                _pickImage(ImageSource.camera);
              }, icon: Icon(Icons.camera_alt,size: 80,color: Colors.grey,),),
             IconButton(onPressed: (){
               _pickImage(ImageSource.gallery);
             }, icon:  Icon(Icons.image,size: 80,color: Colors.grey,))
          ],)
        ],),
      );
    });
  }

  _pickImage(ImageSource imagesource)async{
    try{
      final photo=await ImagePicker().pickImage(source: imagesource);
      if(photo==null)return;
      final tempimage=File(photo.path);
      setState(() {
        pickedimage=tempimage;
      });
    }
    catch(ex){
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ex.toString()),backgroundColor: Color(0XFF00A884),));
    }
  }

    Future<void> uploadProfile() async{
        
        if(pickedimage==null){
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('please upload profile image',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),backgroundColor: Colors.red,));
        }
        else{
        await FirebaseStorage.instance.ref().child('chatUserProfile/${widget.userName}${widget.phoneNumber}').putFile(pickedimage!);
        profileUrl= await FirebaseStorage.instance.ref().child('chatUserProfile/${widget.userName}${widget.phoneNumber}').getDownloadURL();   
        }
      
    }

  Future<void> registerUser() async{
   await FirebaseAuth.instance.createUserWithEmailAndPassword(email: widget.userName+'@gmail.com', password: widget.password);
   await uploadProfile();
   FirebaseFirestore.instance.collection('chatUsers').doc('${FirebaseAuth.instance.currentUser!.uid}').set({
    'uid':FirebaseAuth.instance.currentUser!.uid,
    'userName':widget.userName,
    'phone':widget.phoneCode+widget.phoneNumber,
    'profile':profileUrl,
    'addList':[],
    'bio':nameController.text,
    'isOnline':false,
    'totalChats':0,
    'currentStatus':false,
   }).then((value){
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SuccessFully Registered',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),backgroundColor: Colors.green,));
   Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context)=>HomeScreen()));
   });
  
  }
}

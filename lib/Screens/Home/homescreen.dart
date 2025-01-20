import 'package:flutter/material.dart';
import 'package:baatchit/Screens/Home/Calls/callsscreen.dart';
import 'package:baatchit/Screens/Home/Camera/camerascreen.dart';
import 'package:baatchit/Screens/Home/Chats/chat_home_screen.dart';
import 'package:baatchit/Screens/Home/Status/statusscreen.dart';
import 'package:baatchit/Widgets/uihelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {



  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.collection('chatUsers').doc(FirebaseAuth.instance.currentUser!.uid).update({
      'isOnline':true,
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.camera_alt),
              ),
              Tab(
                text: "CHATS",
              ),
              Tab(
                text: "STATUS",
              ),
              Tab(
                text: "CALLS",
              )
            ],
            indicatorColor: Colors.white,
          ),
          toolbarHeight: 100,
          title: UiHelper.CustomText(
              text: "WhatsApp", height: 20, color: Colors.white,fontweight: FontWeight.bold),
          actions: [
            IconButton(
                onPressed: () {},
                icon: Image.asset("assets/images/Search.png")),
            IconButton(onPressed: (){}, icon: Icon(Icons.more_vert_sharp))
          ],
        ),
        body: TabBarView(children: [
          CameraScreen(),
          ChatsScreen(fromForward: false,),
          StatusScreen(),
          CallsScreen()
        ]),
      ),
    );
      }
      @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    FirebaseFirestore.instance.collection('chatUsers').doc(FirebaseAuth.instance.currentUser!.uid).update({
       'isOnline':false,
    });
  }
}

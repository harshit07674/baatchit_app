import 'package:baatchit/Screens/Home/Chats/chat_messages_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:baatchit/Widgets/uihelper.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/contact.dart';
import '../Contact/contactscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';

class ChatsScreen extends StatefulWidget {
  bool fromForward;
  String? message;
  bool? isForwardImage;
  String? fileType;
  
  ChatsScreen({required this.fromForward,this.message,this.isForwardImage,this.fileType});
  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  PermissionStatus permission = PermissionStatus.denied;

  late Future<List> contacts;
  List<Contact> phoneNumbers=[];
      List<Phone> phones=[];
      List<String> numbers=[];

 Future<List> getContactsList() async{
  
  final val = await FlutterContacts.requestPermission();
    // if(val==true){
    //   permission=PermissionStatus.granted;
    //   await FlutterContacts.getContacts(withProperties: true).then((contact){
    //  for(var data in contact){
    //   phoneNumbers.add(data.phones.first.number);
    //  }
    // });
    // print(permission);
    // }
    // else{
    //   permission=PermissionStatus.denied;
    //   print(permission);
    // }

    if(await FlutterContacts.requestPermission()){
     List<Contact> contact= await FlutterContacts.getContacts(withProperties: true);
     for(var data in contact){
      phoneNumbers.add(data);
  
                    
                           
     phones.addAll(data.phones);
                           
     }
     
    
   
   
    for(var phoneNumber in phones){
      numbers.add(phoneNumber.normalizedNumber);
     }
     setState(() {
       
     });
   
    }
     
    else{
    
       await FlutterContacts.requestPermission();
              
             
                  
               
                
     
    }

    return phoneNumbers;
    
  }
 
 String userPhone='';
 String userProfile='';

@override
  void initState() {
    // TODO: implement initState
    super.initState();
   contacts= getContactsList();
  FirebaseFirestore.instance.collection('chatUsers').doc(FirebaseAuth.instance.currentUser!.uid).get().then((data){
     userPhone=data.data()!['phone'];
    
      userProfile=data.data()!['profile'];
 
  });
                      
  
  }
  var arrContent = [
    {
      "images":
          "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
      "name": "Aron",
      "lastmsg": "Lorem Ipsum",
      "time": "05:45 am",
      "msg": "7"
    },
    {
      "images":
          "https://images.healthshots.com/healthshots/en/uploads/2020/12/08182549/positive-person.jpg",
      "name": "Aron1",
      "lastmsg": "Flutter",
      "time": "06:45 am",
      "msg": "1"
    },
    {
      "images":
          "https://digitalnectar.in/wp-content/uploads/2024/04/banner-right-img.webp",
      "name": "WSCUBETECH",
      "lastmsg": "Flutter Batch is Starting",
      "time": "07:45 am",
      "msg": "2"
    },
    {
      "images":
          "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
      "name": "Aron",
      "lastmsg": "Lorem Ipsum",
      "time": "05:45 am",
      "msg": "7"
    },
    {
      "images":
          "https://images.healthshots.com/healthshots/en/uploads/2020/12/08182549/positive-person.jpg",
      "name": "Aron1",
      "lastmsg": "Flutter",
      "time": "06:45 am",
      "msg": "1"
    },
    {
      "images":
          "https://digitalnectar.in/wp-content/uploads/2024/04/banner-right-img.webp",
      "name": "WSCUBETECH",
      "lastmsg": "Flutter Batch is Starting",
      "time": "07:45 am",
      "msg": "2"
    },
    {
      "images":
          "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
      "name": "Aron",
      "lastmsg": "Lorem Ipsum",
      "time": "05:45 am",
      "msg": "7"
    },
    {
      "images":
          "https://images.healthshots.com/healthshots/en/uploads/2020/12/08182549/positive-person.jpg",
      "name": "Aron1",
      "lastmsg": "Flutter",
      "time": "06:45 am",
      "msg": "1"
    },
    {
      "images":
          "https://digitalnectar.in/wp-content/uploads/2024/04/banner-right-img.webp",
      "name": "WSCUBETECH",
      "lastmsg": "Flutter Batch is Starting",
      "time": "07:45 am",
      "msg": "2"
    }
  ];
 bool isSelected=false;
 int currIndex=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
          future: contacts,
          builder: (context,snapshots) {
            if(snapshots.hasData){
            return Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                // permission.isDenied?Row(
                //   children: [
                //   Text(
                //   'You have denied Permission,Please try again later',style: TextStyle(color: Colors.red),),
                //   ElevatedButton(onPressed: (){
            
                //   },
                //   child: Text('Give Permission',style: TextStyle(color: Colors.white),),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue,
                //     elevation: 3,
            
                //   ),
                //   )
                //   ]):
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('chatUsers').snapshots(),
                    builder: (context, snapshot) {
                      
                      if(snapshot.hasData){
                      return ListView.builder(
                        itemBuilder: (context, index) {
                        
                          //  print(snapshot.data!.docs[index]['phone']);
                          //  print(numbers.where((cont){
                          //    return cont.replaceAll('(','').compareTo(snapshot.data!.docs[index]['phone'])==0;
                          //  }).isNotEmpty);
                            if(numbers.where((cont){
                             return cont.replaceAll('(','').compareTo(snapshot.data!.docs[index]['phone'])==0;
                           }).isNotEmpty){
                            var data = snapshot.data!.docs[index];
                            List<String> chats = [data['phone'],userPhone];
                            chats.sort();
                            String chatRoomId = chats.join('_');
                            return StreamBuilder(stream: FirebaseFirestore.instance.collection('chats').doc(chatRoomId).collection('messages').where('isRead',isEqualTo: false).snapshots(), builder: (context,snapshots){ 
                             int? chatCount;
                             String lastSeenMsg='';
                            if(snapshots.hasData){
                             int chatCount = snapshots.data!.docs.where((chatItem){
                              return chatItem.data()!['senderId']!=FirebaseAuth.instance.currentUser!.uid;
                             }).length;
                          
                             
                          return GestureDetector(
                            onTap: (){
                              if(widget.fromForward==true){
                                setState(() {
                                  isSelected=true;
                                  currIndex=index;
                                });
                              }
                              else{
                              
                              Navigator.push(context, new MaterialPageRoute(builder:(context)=> ChatMessagesScreen(userPhone1: userPhone, userPhone2: snapshot.data!.docs[index]['phone'], profile: snapshot.data!.docs[index]['profile'], name: snapshot.data!.docs[index]['userName'],userId: snapshot.data!.docs[index]['uid'],)));
                              }
                            },
                            child: Container(
                              color: isSelected && currIndex==index?Colors.amberAccent:Colors.transparent,
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      NetworkImage(snapshot.data!.docs[index]["profile"].toString()),
                                ),
                                title: UiHelper.CustomText(
                                    text: '@'+snapshot.data!.docs[index]['userName'].toString(),
                                    height: 14,
                                    fontweight: FontWeight.bold),
                                subtitle: UiHelper.CustomText(
                                    text: lastSeenMsg,
                                    height: 13,
                                    color: Color(0XFF889095)),
                                trailing:isSelected && currIndex==index?IconButton(onPressed: (){
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
                          
                          String chatTime = hourFormat.toString()+':'+minuteFormat+meidianCode;
                          int chatUploadId = DateTime.now().millisecondsSinceEpoch;
                                     FirebaseFirestore.instance.collection('chats').doc(chatRoomId).collection('messages').doc(FirebaseAuth.instance.currentUser!.uid+chatUploadId.toString()).set({
                                      'chatId':chatUploadId.toString(),
                            'message':widget.message,
                            'isImage':widget.isForwardImage,
                            'isReply':false,
                            'isForward':true,
                            'replyFileName':'',
                            'replyToMessage':'',
                            'replyToChatType':'',
                            'replyToChatId':'',
                            'fileType':widget.fileType,
                            'senderId':FirebaseAuth.instance.currentUser!.uid,
                            'chatUploadDate':chatDate,
                            'chatTime':chatTime,
                            'isRead':false,
                            'senderProfile':userProfile,
                            'reactions':[],
                                     }).then((v){
                                      Navigator.pop(context);
                                     });
                                }, icon: Icon(Icons.send,color: Colors.green,size: 40,)): Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    
                                    CircleAvatar(
                                      radius: 8,
                                      backgroundColor:chatCount>0? Color(0XFF036A01):Colors.transparent,
                                      child: UiHelper.CustomText(
                                          text:chatCount>0?'${chatCount}':'',
                                          height: 12,
                                          color: Color(0XFFFFFFFF)),

                                    ),
                                    
                                    
                                  ],
                                ),
                              ),
                            ),
                          );
                            }
                            else{
                              if(snapshots.hasError){
                                return Center(child: Text('${snapshots.error}',style: TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),),);
                              }
                              else{
                                return Center(child: CircularProgressIndicator(color: Colors.blue,),);
                              }
                            }
                            }

                            );
                          }
                          else{
                            return Container();
                          }
                         },
                        itemCount: snapshot.data!.docs.length,
                      );
            }
                    else{
                      if(snapshot.hasError){
                        return Center(child:Text('${snapshot.error}'));
                      }
                      else{
                        return Center(child:CircularProgressIndicator(color:Colors.blue));
                      }
                    }
                    }
                    
                  ),
                ),
              ],
            );
            }
            else{
              if(snapshots.hasError){
                return Center(child:Text('error: ${snapshots.error}',style: TextStyle(color: Colors.red),));
              }
              else{
                return Center(child:CircularProgressIndicator(color: Colors.blue,),);
              }
            }
          }
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ContactScreen()));
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Color(0XFF008665),
            child: Image.asset("assets/images/mode_comment_black_24dp 1.png"),
          ),
        ));
  }
}

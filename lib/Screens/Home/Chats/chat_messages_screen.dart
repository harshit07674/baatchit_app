import 'package:baatchit/Screens/Home/Chats/file_display_screen.dart';
import 'package:baatchit/Screens/Home/Chats/file_view_screen.dart';
import 'package:baatchit/Screens/Home/Chats/image_display_screen.dart';
import 'package:baatchit/Screens/Home/Chats/image_send_screen.dart';
import 'package:baatchit/Screens/Home/Chats/chat_home_screen.dart';
import 'package:baatchit/utils/file_type_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';



class ChatMessagesScreen extends StatefulWidget {
  String userPhone1;
  String userPhone2;
  String profile;
  String name;
  String userId;
  ChatMessagesScreen({super.key,required this.userPhone1,required this.userPhone2,required this.profile,required this.name,required this.userId});

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}


class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  TextEditingController ChatMessageContrller = TextEditingController();
  String chatroomId = '';
  String userProfile='';
  bool isReply=false;
  bool isAppIcon=false;
  bool isCopyIcon=false;
  int currIndex=-1;
  String desc='';
  String replytoChatType='';
  String replyToChatId='';
  List<File> imageFile=[];
  String fileName='';
  File? videoFile;
  File? anyFile;
  File? audioFile;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    List<String> chatId = [widget.userPhone1,widget.userPhone2];
    chatId.sort();
    chatroomId = chatId.join('_');
    FirebaseFirestore.instance.collection('chatUsers').doc(FirebaseAuth.instance.currentUser!.uid).get().then((data){
      userProfile=data.data()!['profile'];
    });
    
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chatUsers').doc(widget.userId).snapshots(),
      builder: (context, snapshots) {
        if(snapshots.hasData){
        return Scaffold(
          appBar: AppBar(
            actions:  isAppIcon?[IconButton(icon:Icon(Icons.reply,color: Colors.black,size: 35,),onPressed: (){
              setState(() {
                isReply=true;
              });
            },),IconButton(icon:Icon(Icons.forward,color: Colors.black,size: 35,),onPressed: (){
                        Navigator.pushReplacement(context,new MaterialPageRoute(builder:(context)=>ChatsScreen(fromForward: true,isForwardImage: replytoChatType=='image'?true:false,fileType: replytoChatType,message: desc,)));
            },),isCopyIcon? IconButton(icon:Icon(Icons.copy,color: Colors.black,size: 35,),onPressed: (){
                Clipboard.setData(ClipboardData(text: '${desc}'));
            },):Container(),]:[],
           leading: Container(decoration: BoxDecoration(shape: BoxShape.circle,image: DecorationImage(image: NetworkImage(widget.profile,),fit: BoxFit.fill)),margin: EdgeInsets.all(5),),
           title: Row(
             children: [
               snapshots.data!.data()!['isOnline']==true?Icon(Icons.circle,color: Colors.green,size: 35,):Icon(Icons.circle,color: Colors.red,size: 35,),
               Text(widget.name,style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic), 
               
                   ),
             ],
           ),
               
               centerTitle: true,
               backgroundColor: Colors.green,
          ),
        body: GestureDetector(
          onTap: (){
            setState(() {
              isAppIcon=false;
              isReply=false;
              desc='';
              replytoChatType='';
              fileName='';
            });
          },
          child: Container(
            child: Column(
             
              children: [
                Expanded(flex: 8,child: StreamBuilder(stream: FirebaseFirestore.instance.collection('chats').doc(chatroomId).collection('messages').snapshots(), builder:(context,snapshot){
                  if(snapshot.hasData){
                  return ListView.builder(
                    
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context,index){
                    var data = snapshot.data!.docs[index];
                    if(data['isRead']==false && FirebaseAuth.instance.currentUser!.uid != data['senderId']){
                    FirebaseFirestore.instance.collection('chats').doc(chatroomId).collection('messages').doc(data['senderId']+data['chatId']).update({
                      'isRead':true,
                    });
                    }
                    return GestureDetector(
                      onHorizontalDragStart: (tp){
                        if(tp.localPosition!=Offset(0,0)){
                        setState(() {
                          isAppIcon=true;
                          currIndex=index;
                          
                          if(data['isImage']==true){
                          desc=data['message'][0];
                          }
                          else{
                          desc=snapshot.data!.docs[index]['message'];
                          }
                          replytoChatType=data['fileType'];
                          if(data['fileType']=='text'){
                            isCopyIcon=true;
                            setState(() {
                              
                            });
                          }
                          else{
                            isCopyIcon=false;
                            setState(() {
                              
                            });
                          }
                          replyToChatId=data['chatId'];
                          if(replytoChatType=='video'||replytoChatType=='audio'||replytoChatType=='otherFiles'||data['isImage']==true){
                            fileName=data['fileName'];
                          }
                        });
                        }
                        
                      },
                      onHorizontalDragCancel: (){
                       setState(() {
                          isAppIcon=false;
                        });
                      },
                      
                      
                      child: Container(
                       margin: EdgeInsets.all(7),
                       padding: EdgeInsets.all(5),
                    
                       child: data['isImage']==true?GestureDetector(
                        onTap: (){
                        Navigator.push(context, new MaterialPageRoute(builder:(context)=> ImagesDisplayScreen(chatId:chatroomId,sender:data['senderId'],uploadId:data['chatId'])));
                        },
                        child: Column(
                          children: [
                            data['isForward']==true?Text('Forwarded Message'):Text(''),
                            data['isReply']==true?Opacity(
                                  opacity: 0.7,
                                   child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.lightGreenAccent,
                                      border: Border(right: BorderSide(color: Colors.black,width: 2),bottom: BorderSide(color: Colors.black,width: 2))
                                    ),
                                    height: 100,
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child:data['replyToChatType']=='image'?Container(
                                      height: 50,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(image: NetworkImage('${data['replyToMessage']}')),
                                      ),
                                    ):data['replyToChatType']=='video'||data['replyToChatType']=='audio'||data['replyToChatType']=='otherFiles'?Container(
                                      height: 50,
                                      width: 100,
                                      child: Row(
                                        children: [
                                          Icon(Icons.file_copy,color: Colors.blue,size: 40,),
                                          const SizedBox(width: 10,),
                                          Container(height: 50,width: MediaQuery.of(context).size.width*0.5, child: Text('${data['replyFileName']}',overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                    ): Text('${data['replyToMessage']}',overflow: TextOverflow.clip,),
                                                               ),
                                 ):Container(),
                                 data['isReply']==true?Text('Reply'):Text(''),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: data['senderId']==FirebaseAuth.instance.currentUser!.uid?MainAxisAlignment.end:MainAxisAlignment.start,
                              children: [
                                Center(child: data['isRead']==true?Icon(Icons.check,color: Colors.blue,size:40):Container(),),
                                 Column(
                                  children: [
                                    
                                    Container(
                                      margin: EdgeInsets.all(0),
                                      height: MediaQuery.of(context).size.height*0.4,
                                      width: MediaQuery.of(context).size.width*0.5,
                                      decoration: BoxDecoration(
                                           color: isAppIcon && currIndex==index?Colors.lightGreenAccent.shade100:Colors.transparent,
                                        image: DecorationImage(image: NetworkImage('${data['message'][0]}'),fit: BoxFit.cover,opacity: 0.5),
                                      ),
                                      child: Center(child: Text('click to view Images',style: TextStyle(color: Colors.red,fontSize: 14,),),),
                                    ),
                                
                                  
                                       Container(
                                        padding: EdgeInsets.all(7),
                                       color: data['senderId']==FirebaseAuth.instance.currentUser!.uid?Colors.lightGreenAccent:Colors.greenAccent,
                                       child: Text(data['caption'],style: TextStyle(fontSize: 18),),
                                      ),
                                    
                                  ],
                                ),
                                const SizedBox(width: 10,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  
                                  children: [
                                   
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black),
                                        image: DecorationImage(image: NetworkImage('${data['senderProfile']}'),fit: BoxFit.fill)
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Text('${data['chatUploadDate']}',style: TextStyle(color: Colors.green,fontSize: 10,fontWeight: FontWeight.bold),),
                                    Text('${data['chatTime']}',style: TextStyle(color: Colors.green,fontSize: 10,fontWeight: FontWeight.bold),),
                                  ],
                                ),
                                
                              ],
                            ),
                          ],
                        ),
                       ):data['fileType']=='video'||data['fileType']=='audio'||data['fileType']=='otherFiles'?GestureDetector(
                        onTap: () async{
                          if(data['fileType']=='otherFiles'){
                                final result = await http.get(Uri.parse(data['message']));
                                Directory directory = await getApplicationDocumentsDirectory();
                                // if(File('${directory.path}/document${data['chatId']}.pdf').exists()==false){
                                File file =  await File('${directory.path}/${data['fileName']}').create();
                                 await file.writeAsBytes(result.bodyBytes);
                                 OpenFile.open(file.path);
                               
                                // else{
                                //   OpenFile.open('${directory.path}/document${data['chatId']}');
                                // }
                               }
                               else{
                         showAdaptiveDialog(context: context, builder: (context){
                               
                                return Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.transparent,
                                  child: FileViewDialog(fileType: data['fileType'], fileUrl: data['message'],audioTime: data['chatId'],)
                                );
                           
                          });
                               }
                        },
                         child: Column(
                           children: [
                             data['isForward']==true?Text('Forwarded Message'):Text(''),
                            data['isReply']==true?Opacity(
                                  opacity: 0.7,
                                   child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.lightGreenAccent,
                                      border: Border(right: BorderSide(color: Colors.black,width: 2),bottom: BorderSide(color: Colors.black,width: 2))
                                    ),
                                    height: 100,
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child:data['replyToChatType']=='image'?Container(
                                      height: 50,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(image: NetworkImage('${data['replyToMessage']}')),
                                      ),
                                    ):data['replyToChatType']=='video'||data['replyToChatType']=='audio'||data['replyToChatType']=='otherFiles'?Container(
                                      height: 50,
                                      width: 100,
                                      child: Row(
                                        children: [
                                          Icon(Icons.file_copy,color: Colors.blue,size: 40,),
                                          const SizedBox(width: 10,),
                                          Container(height: 50,width: MediaQuery.of(context).size.width*0.5, child: Text('${data['replyFileName']}',overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                    ): Text('${data['replyToMessage']}',overflow: TextOverflow.clip,),
                                                               ),
                                 ):Container(),
                                 data['isReply']==true?Text('Reply'):Text(''),
                             Container(
                              height: MediaQuery.of(context).size.height*0.1,
                              width: MediaQuery.of(context).size.width*0.7,
                              margin: EdgeInsets.only(left: 120,right:10),
                              decoration: BoxDecoration(
                                
                                   color: isAppIcon && currIndex==index ?Colors.lightGreenAccent.shade100:Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                
                              ),
                              child: 
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(left: 10,right: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(20),
                                        color: data['senderId']==FirebaseAuth.instance.currentUser!.uid?Colors.lightGreenAccent:Colors.greenAccent
                                      ),
                                      child: Row(
                                        children: [
                                      Icon(data['fileType']=='video'?Icons.videocam:data['fileType']=='audio'?Icons.audiotrack_rounded:Icons.preview,color: Colors.blue,size: 40,),
                                      
                                      Text('${data['fileType']=='otherFiles'?'File':'${data['fileType']}'}',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                                       Container(
                                        height: 50,
                                        width: MediaQuery.of(context).size.width*0.2,
                                        alignment: Alignment.center,
                                       child: Text('Click',style: TextStyle(color: Colors.red,fontSize: 24,fontWeight: FontWeight.bold),) 
                                      ),
                                        ],
                                               
                                      ),
                                    ),
                                      Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    
                                    children: [
                                     
                                      Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.black),
                                          image: DecorationImage(image: NetworkImage('${data['senderProfile']}'),fit: BoxFit.fill)
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      Text('${data['chatUploadDate']}',style: TextStyle(color: Colors.green,fontSize: 10,fontWeight: FontWeight.bold),),
                                      Text('${data['chatTime']}',style: TextStyle(color: Colors.green,fontSize: 10,fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                  ],
                              
                              ),
                             ),
                           ],
                         ),
                       ): Row(
                        
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: data['senderId']==FirebaseAuth.instance.currentUser!.uid?MainAxisAlignment.end:MainAxisAlignment.start,
                          children: [
                        
                            Center(child: data['isRead']==true?Icon(Icons.check,color: Colors.blue,size:40):Container(),),
                             Column(
                              children: [
                                     data['isForward']==true?Text('Forwarded Message'):Text(''),
                                 data['isReply']==true?Opacity(
                                  opacity: 0.7,
                                   child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.lightGreenAccent,
                                      border: Border(right: BorderSide(color: Colors.black,width: 2),bottom: BorderSide(color: Colors.black,width: 2))
                                    ),
                                    height: 100,
                                    width: MediaQuery.of(context).size.width*0.7,
                                    child:data['replyToChatType']=='image'?Container(
                                      height: 50,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(image: NetworkImage('${data['replyToMessage']}')),
                                      ),
                                    ):data['replyToChatType']=='video'||data['replyToChatType']=='audio'||data['replyToChatType']=='otherFiles'?Container(
                                      height: 50,
                                      width: 100,
                                      child: Row(
                                        children: [
                                          Icon(Icons.file_copy,color: Colors.blue,size: 40,),
                                          const SizedBox(width: 10,),
                                          Container(height: 50,width: MediaQuery.of(context).size.width*0.5, child: Text('${data['replyFileName']}',overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                    ): Text('${data['replyToMessage']}',overflow: TextOverflow.clip,),
                                                               ),
                                 ):Container(),
                                 data['isReply']==true?Text('Reply'):Text(''),
                                Container(

                                  
                                   color: isAppIcon && currIndex==index ?Colors.green:Colors.transparent,
                                  child: Container(
                                    margin: EdgeInsets.all(0),
                                   
                                    
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: data['senderId']==FirebaseAuth.instance.currentUser!.uid?Colors.lightGreenAccent:Colors.greenAccent,
                                      borderRadius: BorderRadius.circular(20)
                                      
                                    ),
                                    child: Center(child: Text('${data['message']}',style: TextStyle(color: Colors.red,fontSize: 14,),overflow: TextOverflow.clip,),),
                                  ),
                                ),
                            
                              
                                
                              ],
                            ),
                            const SizedBox(width: 10,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              
                              children: [
                               
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black),
                                    image: DecorationImage(image: NetworkImage('${data['senderProfile']}'),fit: BoxFit.fill)
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                Text('${data['chatUploadDate']}',style: TextStyle(color: Colors.green,fontSize: 10,fontWeight: FontWeight.bold),),
                                Text('${data['chatTime']}',style: TextStyle(color: Colors.green,fontSize: 10,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            
                          ],
                        
                       ),
                      ),
                    );
                    });
                  //  return Container(
                  
                  //   margin: EdgeInsets.all(10),
                  //   alignment: snapshot.data!.docs[index]['senderId']==FirebaseAuth.instance.currentUser!.uid?Alignment.topRight:Alignment.topLeft,
                  //   child: Row(
                      
                  //     mainAxisAlignment: data['senderId']==FirebaseAuth.instance.currentUser!.uid?MainAxisAlignment.end:MainAxisAlignment.start,
                  //     children: [
                  //      Column(
                        
                  //        children: [
                  //         Text('${snapshot.data!.docs[index]['chatUploadDate'].toString()}',style: TextStyle(color: Colors.black,fontSize: 10,fontWeight: FontWeight.bold),),
                  //         Text('${snapshot.data!.docs[index]['chatTime']}',style: TextStyle(color: Colors.black,fontSize: 10,fontWeight: FontWeight.bold),),
                  //          Container(
                  //           height: 30,
                  //           width: 30,
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             image: DecorationImage(image: NetworkImage(snapshot.data!.docs[index]['senderProfile']),fit: BoxFit.fill),
                  //           ),
                  //          ),
                       
                  //        ],
                  //      ),
                  //       const SizedBox(width: 10,),
                  //      Flexible(
                  //       fit: FlexFit.loose,
                  //       child: Container(
                  //       padding: EdgeInsets.all(7),
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(20),
                  //     color: snapshot.data!.docs[index]['senderId']==FirebaseAuth.instance.currentUser!.uid?Colors.green:Colors.lightGreenAccent
                  //   ),
                  //       child:data['isImage']==true? 
                           
            
            
                  //          Column(
                  //           children: [
                  //             Expanded(child: Image.network('${snapshot.data!.docs[index]['message'][0]}',fit: BoxFit.fill,),flex: 2,),
                  //             snapshot.data!.docs[index]['message'].length>=2?Expanded(child: Image.network('${snapshot.data!.docs[index]['message'][1]}',fit: BoxFit.fill,),flex: 2,):Container(),
                  //             Container(
                  //               color: Colors.amber,
                  //               child: Text('${snapshot.data!.docs[index]['caption']}',overflow: TextOverflow.clip,),
                  //             )
                  //           ],
                  //         )
                  //       : Text('${snapshot.data!.docs[index]['message']}',overflow: TextOverflow.clip,),
                  //      )),
                  //      data['isRead']==true?Icon(Icons.check_circle,color: Colors.blue,size: 35,):Icon(Icons.check_circle_outline,color: Colors.black,size: 35,)
                  //   ],),);
                   
                  //  :Container(
                  
                  //   margin: EdgeInsets.all(10),
                  //   alignment: snapshot.data!.docs[index]['senderId']==FirebaseAuth.instance.currentUser!.uid?Alignment.topRight:Alignment.topLeft,
                  //   child: Row(
                      
                  //     mainAxisAlignment: data['senderId']==FirebaseAuth.instance.currentUser!.uid?MainAxisAlignment.end:MainAxisAlignment.start,
                  //     children: [
                  //      Column(
                        
                  //        children: [
                  //         Text('${snapshot.data!.docs[index]['chatUploadDate'].toString()}',style: TextStyle(color: Colors.black,fontSize: 10,fontWeight: FontWeight.bold),),
                  //         Text('${snapshot.data!.docs[index]['chatTime']}',style: TextStyle(color: Colors.black,fontSize: 10,fontWeight: FontWeight.bold),),
                  //          Container(
                  //           height: 30,
                  //           width: 30,
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             image: DecorationImage(image: NetworkImage(snapshot.data!.docs[index]['senderProfile']),fit: BoxFit.fill),
                  //           ),
                  //          ),
                       
                  //        ],
                  //      ),
                  //       const SizedBox(width: 10,),
                  //      Flexible(
                  //       fit: FlexFit.loose,
                  //       child: Container(
                  //       padding: EdgeInsets.all(7),
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(20),
                  //     color: snapshot.data!.docs[index]['senderId']==FirebaseAuth.instance.currentUser!.uid?Colors.green:Colors.lightGreenAccent
                  //   ),
                  //       child:data['isImage']==true? 
                           
            
            
                  //          Column(
                  //           children: [
                  //             Expanded(child: Image.network('${snapshot.data!.docs[index]['message'][0]}',fit: BoxFit.fill,),flex: 2,),
                  //             snapshot.data!.docs[index]['message'].length>=2?Expanded(child: Image.network('${snapshot.data!.docs[index]['message'][1]}',fit: BoxFit.fill,),flex: 2,):Container(),
                  //             Container(
                  //               color: Colors.amber,
                  //               child: Text('${snapshot.data!.docs[index]['caption']}',overflow: TextOverflow.clip,),
                  //             )
                  //           ],
                  //         )
                  //       : Text('${snapshot.data!.docs[index]['message']}',overflow: TextOverflow.clip,),
                  //      )),
                  //      data['isRead']==true?Icon(Icons.check_circle,color: Colors.blue,size: 35,):Icon(Icons.check_circle_outline,color: Colors.black,size: 35,)
                  //   ],),);
                  
                  // });
                  }
                  else{
                    if(snapshot.hasError){
                       return Center(child: Text('${snapshot.error}'),);
                    }
                    else{
                    return Center(child: CircularProgressIndicator(color: Colors.blue,),);
                    }
                  }
                }),),
                isReply?Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width*0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border(top: BorderSide(color: Colors.black),right: BorderSide(color: Colors.black)),
                        color: Colors.lightGreenAccent,
                      ),
                      child: replytoChatType=='video' ||replytoChatType=='audio'||replytoChatType=='otherFiles'|| replytoChatType=='image'?Row(
                        children: [
                          Icon(Icons.file_copy,color: Colors.blue,size: 35,),
                          const SizedBox(width: 10,),
                          Container(
                            height: 30,
                            width: MediaQuery.of(context).size.width*0.7,
                            child: Text('${fileName}',overflow: TextOverflow.ellipsis,)),
                        ],
                      ):Text('${desc}',overflow: TextOverflow.clip,),
                    ):Container(),
                Expanded(child: 
                       Row (children:[IconButton(onPressed: (){
                                               _openBottom(context);
                            }, icon: Icon(Icons.image,color: Colors.green,size: 35,)),
                            const SizedBox(width: 10,),
                            IconButton(onPressed: () async{
                                return showDialog(context: context,  builder: (context){
                                    return Scaffold(
                                      backgroundColor: Colors.transparent,
                                      
                                      body: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 75,left: 20,right: 20),
                                          height: MediaQuery.of(context).size.height*0.5,
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(20)
                                          ),
                                          child: Column(
                                           
                                            children: [
                                             IconButton(onPressed: (){
                                                     ImagePicker().pickVideo(source: ImageSource.gallery).then((data){
                                                           videoFile=File(data!.path);
                                                        Navigator.push(context,new MaterialPageRoute(builder: (context)=>FileDisplayScreen(type: 'video', typeFile: videoFile!, chatId: chatroomId, userProfile: userProfile)));
                                                     });       
                                             }, icon:Icon(Icons.video_camera_back,color: Colors.blue,size: 35,)),
                                             Text('upload video',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                                             const SizedBox(height: 10,),
                                             IconButton(onPressed: (){
                                                    FilePicker.platform.pickFiles(
                                                      allowMultiple: false,
                                                    type: FileType.any,
                                                    allowCompression: true,
                                                    ).then((data){
                                                     anyFile = File(data!.xFiles.first.path);
                                                     Navigator.push(context, new MaterialPageRoute(builder: (context)=>FileDisplayScreen(type: 'otherFiles', typeFile: anyFile!, chatId: chatroomId, userProfile: userProfile)));
                                                    });
                                             }, icon:Icon(Icons.file_open,color: Colors.blue,size: 35,)),
                                             Text('upload file',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                                             const SizedBox(height: 10,),
                                             IconButton(onPressed: (){
                                                    FilePicker.platform.pickFiles(
                                                      allowCompression: true,
                                                      allowMultiple: false,
                                                      type: FileType.audio,
                                                    ).then((data){
                                                        audioFile= File(data!.xFiles.first.path);
                                                        Navigator.push(context, new MaterialPageRoute(builder: (context)=>FileDisplayScreen(type: 'audio', typeFile:audioFile!, chatId: chatroomId, userProfile: userProfile)));
                                                    });
                                             }, icon:Icon(Icons.audio_file,color: Colors.blue,size: 35,)),
                                             Text('upload audio',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                                            ],
                                          )
                                        ),
                                      ),
                                    );
                                });
                            }, icon: Icon(Icons.attachment,color: Colors.green,size: 35,)),
                            
                            
                                
                            
                          
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width*0.6,
                      child: TextField(
                        controller: ChatMessageContrller,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                             borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                             borderRadius: BorderRadius.circular(20),
                          ),
                          fillColor: Colors.lightGreen,
                          filled: true,
                        ),),
                    ),
                     IconButton(onPressed: (){
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
                               FirebaseFirestore.instance.collection('chats').doc(chatroomId).collection('messages').doc(FirebaseAuth.instance.currentUser!.uid+chatUploadId.toString()).set({
                                'chatId':chatUploadId.toString(),
                                'message':ChatMessageContrller.text,
                                'isImage':false,
                                'isReply':isReply,
                                'isForward':false,
                                'replyFileName':fileName,
                                'replyToMessage':desc,
                                'replyToChatType':replytoChatType,
                                'replyToChatId':replyToChatId,
                                'fileType':'text',
                                'senderId':FirebaseAuth.instance.currentUser!.uid,
                                'chatUploadDate':chatDate,
                                'chatTime':chatTime,
                                'isRead':false,
                                'senderProfile':userProfile,
                                'reactions':[],
                               }).then((d){
                                ChatMessageContrller.clear();
                                isAppIcon=false;
                                isReply=false;
                                currIndex=-1;
                                desc='';
                                replyToChatId='';
                                replytoChatType='';
                                fileName='';
                                setState(() {
                                  
                                });
                               });
                            }, icon:Icon(Icons.send,size: 35,),),
                       ],),
                flex: 1,)
                // Expanded(child: 
                    
                    // Container(
                    //   height: 70,
                    //   width: MediaQuery.of(context).size.width*0.9,
                      // child: 
                    //   Container(
                    //     child: TextField(
                    //       controller: ChatMessageContrller,
                    //       style: TextStyle(color: Colors.black,fontSize: 20),
                    //       keyboardType: TextInputType.text,
                    //       decoration: InputDecoration(
                    //         border: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(20),
                    //           borderSide: BorderSide(color: Colors.black,width: 2),
                    //         ),
                    //         focusedBorder: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(20),
                    //           borderSide: BorderSide(color: Colors.blue,width: 2),
                    //         ),
                    //         icon: Row (children:[IconButton(onPressed: (){
                    //                            _openBottom(context);
                    //         }, icon: Icon(Icons.image,color: Colors.green,size: 35,)),
                    //         const SizedBox(width: 10,),
                    //         IconButton(onPressed: () async{
                    //             return showDialog(context: context, builder: (context){
                    //                 return Container(
                    //                   height: MediaQuery.of(context).size.height*0.5,
                    //                   width: MediaQuery.of(context).size.width*0.9,
                    //                   color: Colors.black,
                    //                   child: Column(
                                       
                    //                     children: [
                    //                      IconButton(onPressed: (){
                    //                              ImagePicker().pickVideo(source: ImageSource.gallery).then((data){
                    //                                    videoFile=File(data!.path);
                    //                                 Navigator.push(context,new MaterialPageRoute(builder: (context)=>FileDisplayScreen(type: 'video', typeFile: videoFile!, chatId: chatroomId, userProfile: userProfile)));
                    //                              });       
                    //                      }, icon:Icon(Icons.video_camera_back,color: Colors.blue,size: 35,)),
                    //                      Text('upload video',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                    //                      const SizedBox(height: 10,),
                    //                      IconButton(onPressed: (){
                    //                             FilePicker.platform.pickFiles(
                    //                               allowMultiple: false,
                    //                             type: FileType.any,
                    //                             allowCompression: true,
                    //                             ).then((data){
                    //                              anyFile = File(data!.xFiles.first.path);
                    //                              Navigator.push(context, new MaterialPageRoute(builder: (context)=>FileDisplayScreen(type: 'otherFiles', typeFile: anyFile!, chatId: chatroomId, userProfile: userProfile)));
                    //                             });
                    //                      }, icon:Icon(Icons.file_open,color: Colors.blue,size: 35,)),
                    //                      Text('upload file',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                    //                      const SizedBox(height: 10,),
                    //                      IconButton(onPressed: (){
                    //                             FilePicker.platform.pickFiles(
                    //                               allowCompression: true,
                    //                               allowMultiple: false,
                    //                               type: FileType.audio,
                    //                             ).then((data){
                    //                                 audioFile= File(data!.xFiles.first.path);
                    //                                 Navigator.push(context, new MaterialPageRoute(builder: (context)=>FileDisplayScreen(type: 'audio', typeFile:audioFile!, chatId: chatroomId, userProfile: userProfile)));
                    //                             });
                    //                      }, icon:Icon(Icons.audio_file,color: Colors.blue,size: 35,)),
                    //                      Text('upload audio',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                    //                     ],
                    //                   )
                    //                 );
                    //             });
                    //         }, icon: Icon(Icons.attachment,color: Colors.green,size: 35,)),
                            
                    //         ]),
                                
                    //         suffix: IconButton(onPressed: (){
                    //           String chatDate = DateTime.now().day.toString()+'/'+DateTime.now().month.toString()+'/'+DateTime.now().year.toString();
                    //           String minuteFormat = DateTime.now().minute.toString().length<2?'0'+DateTime.now().minute.toString():DateTime.now().minute.toString();
                    //           String hourFormat='';
                    //           String meidianCode='';
                               
                    //            if(DateTime.now().hour==12 || DateTime.now().hour == 24){
                    //             switch(DateTime.now().hour){
                    //               case 12:{
                    //               hourFormat='12';
                    //               meidianCode='pm';
                    //               }
                    //               break;
                    //               case 24:
                    //               {
                    //               hourFormat='12';
                    //               meidianCode='am';
                    //               }
                    //               break;
                                  
                    //             }
                    //            }
                    //            else{
                    //             if(DateTime.now().hour>12){
                    //               hourFormat=(DateTime.now().hour % 12).toString();
                    //               meidianCode='pm';
                    //             }
                    //             else{
                    //               hourFormat=(DateTime.now().hour % 12).toString();
                    //               meidianCode='am';
                    //             }
                    //            }
                              
                    //           String chatTime = hourFormat.toString()+':'+minuteFormat+meidianCode;
                    //           int chatUploadId = DateTime.now().millisecondsSinceEpoch;
                    //            FirebaseFirestore.instance.collection('chats').doc(chatroomId).collection('messages').doc(FirebaseAuth.instance.currentUser!.uid+chatUploadId.toString()).set({
                    //             'chatId':chatUploadId.toString(),
                    //             'message':ChatMessageContrller.text,
                    //             'isImage':false,
                    //             'fileType':'text',
                    //             'senderId':FirebaseAuth.instance.currentUser!.uid,
                    //             'chatUploadDate':chatDate,
                    //             'chatTime':chatTime,
                    //             'isRead':false,
                    //             'senderProfile':userProfile,
                    //             'reactions':[],
                    //            }).then((d){
                    //             ChatMessageContrller.clear();
                    //            });
                    //         }, icon:Icon(Icons.send,size: 35,)),
                    //       ),
                    //     ),
                    //   ),
                    // // ),
                    // flex: 1,),
              ]
            ),
          ),
        ),
        );
        }
        else{
          return CircularProgressIndicator(color: Colors.blue,);
        }
      }
    ));
  
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ChatMessageContrller.clear();
    
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
              IconButton(onPressed: () {
                   
               FilePicker.platform.pickFiles(
                allowMultiple: true,
                type: FileType.image,
               ).then((data){
                  data!.files.forEach((fileItem){
                   imageFile.add(File(fileItem.xFile.path));
                   
                  });
                  Navigator.push(context, new MaterialPageRoute(builder: (context)=>ImageSendScreen(imageFiles: imageFile, chatRoomId: chatroomId, userProfile: userProfile)));
               });
              }, icon: Icon(Icons.image,size: 80,color: Colors.grey,),),
             IconButton(onPressed: (){
              ImagePicker().pickImage(source: ImageSource.gallery).then((data){
                imageFile.add(File(data!.path));
                Navigator.push(context, new MaterialPageRoute(builder: (context)=>ImageSendScreen(imageFiles: imageFile, chatRoomId: chatroomId, userProfile: userProfile)));
              });
             }, icon:  Icon(Icons.camera_alt,size: 80,color: Colors.grey,))
          ],)
        ],),
      );
    });
  }
}
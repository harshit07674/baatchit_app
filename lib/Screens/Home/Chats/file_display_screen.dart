import 'dart:typed_data';

import 'package:baatchit/utils/file_type_enum.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:video_compress/video_compress.dart';



class FileDisplayScreen extends StatefulWidget {
  String type;
  File typeFile;
  String chatId;
  String userProfile;
   
   FileDisplayScreen({super.key,required this.type,required this.typeFile,required this.chatId,required this.userProfile});

  @override
  State<FileDisplayScreen> createState() => _FileDisplayScreenState();
}

class _FileDisplayScreenState extends State<FileDisplayScreen> {
late VideoPlayerController controller;
bool isVolume= false;
bool isPlay=false;
Stream<Duration?> dur = Stream.empty();
final audioPlayer = AudioPlayer();
 TextEditingController captionTextController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.type=='video'){
    controller = VideoPlayerController.file(widget.typeFile)..initialize(
    
    )..addListener((){
      setState(() {
        
      });
    })..play();
    
    }
    else{
      if(widget.type == 'audio'){
       
       setAudio().then((d){
                    
                      audioPlayer.play();
                      audioPlayer.setLoopMode(LoopMode.all);
                    
       });
              
      }
    
    }
     
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        
        body: Column(
          children: [
           Expanded(flex: 8,child: widget.type=='video'? Container(
              height: MediaQuery.of(context).size.height*0.7,
              width: MediaQuery.of(context).size.width*0.8,
              child:Stack(
                children: [
                
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 200,
                    width: MediaQuery.of(context).size.width*0.9,
                    child: VideoPlayer(controller)),
                  Align(alignment: Alignment.bottomRight,child: Row(
                    children: [
                      Text('${0.00}',style: TextStyle(color: Colors.green,fontSize: 18,),),
                      const SizedBox(width: 10,),
                      Icon(isVolume?Icons.volume_off:Icons.volume_down,color: Colors.black,size: 35,),
                      const SizedBox(width: 5,),
                      Center(child: IconButton(onPressed: (){
                               if(controller.value.isPlaying){
                                controller.pause();
                                isPlay=false;
                                setState(() {
                                  
                                });
                               }
                               else{
                                controller.play();
                                isPlay=true;
                                setState(() {
                                  
                                });
                               }     
                      }, icon: Icon(isPlay?Icons.pause_circle:Icons.play_circle,color: Colors.blue,size: 40,)),),
                      const SizedBox(height: 10,),
                      Container(
                        width: MediaQuery.of(context).size.width*0.3,
                        child: Slider(value: controller.value.position.inSeconds.toDouble(),min: 0.0,max: controller.value.duration.inSeconds.toDouble(), onChanged:(value){
                          setState(() {
                        
                            controller.seekTo(Duration(seconds: value.toInt()));
                            
                          });
                          
                        },),
                      ),
                      const SizedBox(width: 10,),
                      Text('${controller.value.position.inMinutes}:${controller.value.position.inSeconds%60}/${controller.value.duration.inMinutes}:${controller.value.duration.inSeconds%60}'),
             
                    ],
                  ),),
                  
                ],
              ),
             ):widget.type=='audio'?Container(
              height: 200,
              width: MediaQuery.of(context).size.width*0.9,
              child:Column(
                children: [
                
                  // Container( A 
                  //   height: 200,
                  //   width: MediaQuery.of(context).size.width*0.8,
                  //   child: 
                    // FutureBuilder(future: JustWaveform.parse(widget.typeFile), builder:(context,snapshot){
                    //    if(snapshot.hasData){
                    //     return CustomPaint(
                    //       size: Size(MediaQuery.of(context).size.width*0.9,170),
                    //       painter: WaveFormPainter(waveForm:  snapshot.data!.data),
                    //     );
                    //    }
                    //    else{
                    //    return CircularProgressIndicator(color: Colors.blue,);
                    //    }
                    // }),),
                  StreamBuilder(stream: widget.typeFile.openRead().skip(audioPlayer.speed.toInt()), builder: (context,snapshot){
                    if(snapshot.hasData){
      
                    return StreamBuilder<Duration?>(
                      stream: audioPlayer.positionStream,
                      builder: (context, snapshots) {
                        if(snapshot.hasData && audioPlayer.duration !=null){
                        return Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width*0.9,
                          child: CustomPaint(painter: WaveFormPainter(waveForm: snapshot.data!.toList(),duration: audioPlayer.duration!,currentPos:snapshots.hasData? snapshots.data!.inSeconds.toDouble():0.0 ),
                          
                          size: Size(100,100),
                          ),
                        );
                      }
                      else{
                        return Center(child: CircularProgressIndicator(color: Colors.blue,),);
                      }
                      }
                    
                    );
                    }
                    else{
                      return Center(child: CircularProgressIndicator(color: Colors.blue,),);
                    }
                  }),
                    const SizedBox(height: 20,),
                    Container(
                      height: 90,
                      width: MediaQuery.of(context).size.width*0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black,width: 2),
                        color: Colors.amberAccent,
                        
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                         Text('${widget.typeFile.path.lastIndexOf('/')}',style: TextStyle(fontWeight: FontWeight.bold),),
                         IconButton(onPressed:(){
                           audioPlayer.seek(Duration(seconds: audioPlayer.duration!.inSeconds+10));
                         }, icon: Icon(Icons.skip_next,color: Colors.blue,size: 35,)),
                         GestureDetector(
                          onTap: (){
                            if(audioPlayer.playing){
                              audioPlayer.pause();
                              setState(() {
                                
                              });
                            }
                            else{
                              audioPlayer.play();
                              setState(() {
                                
                              });
                            }
                          },
                           child: Container(
                            height: 40,
                            width: 40,
                            child: Center(child: Icon(audioPlayer.playing?Icons.pause:Icons.play_arrow,color: Colors.blue,size: 30,),),
                           ),
                         ),
                         IconButton(onPressed: (){
                           audioPlayer.seek(Duration(seconds: audioPlayer.duration!.inSeconds-10));
                         }, icon: Icon(Icons.skip_previous,color: Colors.blue,size: 35,)),
                        ],
                      ),
                    )
                  
                ],
              ),
             ):Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width*0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black,width: 2),
                        
                        
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                         Text('${widget.typeFile.path.split('/')[widget.typeFile.path.split('/').length-1]}',style: TextStyle(fontWeight: FontWeight.bold),),
                         GestureDetector(onTap: () async{
                           final filePath = widget.typeFile.path;
                           
                            await OpenFile.open(filePath);
                           
                           
                           
                           
                         },
                         child: Icon(Icons.file_present_outlined,color: Colors.blue,size: 100,),
                         )
                        
                        ]
        
                      ),),),
           Expanded(child:TextField(
                controller: captionTextController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.blue),
                    
                  ),
                  focusedBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.green),
                    
                    
                  ),
                  hintStyle: TextStyle(color: Colors.grey.shade700),
                  hintText: 'Enter caption',
                  fillColor: Colors.lightGreen,
                  filled: true,
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
                    String mediaUrl='';
                    String chatTime = hourFormat.toString()+':'+minuteFormat+meidianCode;
                    
                    int chatUploadId = DateTime.now().millisecondsSinceEpoch;
                     
                     if(widget.type=='video'){
                     final info= await VideoCompress.compressVideo(widget.typeFile.path,quality: VideoQuality.MediumQuality);
                     widget.typeFile = File(info!.path!);
                     await FirebaseStorage.instance.ref().child('sendMedia/sendVideos/${FirebaseAuth.instance.currentUser!.uid}${chatUploadId}').putFile(widget.typeFile!);
                      mediaUrl= await FirebaseStorage.instance.ref().child('sendMedia/sendVideos/${FirebaseAuth.instance.currentUser!.uid}${chatUploadId}').getDownloadURL();
                     }
                     else{
                      if(widget.type=='audio'){
                        await FirebaseStorage.instance.ref().child('sendMedia/sendAudios/${FirebaseAuth.instance.currentUser!.uid}${chatUploadId}').putFile(widget.typeFile!);
                      mediaUrl= await FirebaseStorage.instance.ref().child('sendMedia/sendAudios/${FirebaseAuth.instance.currentUser!.uid}${chatUploadId}').getDownloadURL();
                      }
                      else{
                        await FirebaseStorage.instance.ref().child('sendMedia/sendFiles/${FirebaseAuth.instance.currentUser!.uid}${chatUploadId}').putFile(widget.typeFile!);
                      mediaUrl= await FirebaseStorage.instance.ref().child('sendMedia/sendFiles/${FirebaseAuth.instance.currentUser!.uid}${chatUploadId}').getDownloadURL();
                      }
                     }
                     
                     List<String> pathList = widget.typeFile.path.split('/');
       int nameIndex=pathList.length-1;
                      String fileName = pathList[nameIndex];
                      
                     FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').doc(FirebaseAuth.instance.currentUser!.uid+chatUploadId.toString()).set({
                      'chatId':chatUploadId.toString(),
                      'message':mediaUrl,
                      'caption':captionTextController.text,
                      'fileType':widget.type,
                      'isReply':false,
                              'isForward':false,
                              'replyFileName':'',
                              'replyToMessage':'',
                              'replyToChatType':'',
                              'replyToChatId':'',
                      'fileName':fileName,
                      'isImage':false,
                      'senderId':FirebaseAuth.instance.currentUser!.uid,
                      'isForward':false,
                      'chatUploadDate':chatDate,
                      'chatTime':chatTime,
                      'isRead':false,
                      'senderProfile':widget.userProfile,
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
      ),
    );
    
  }

  Future<void> setAudio() async{
   final audioSource = AudioSource.file(widget.typeFile.path);
   await audioPlayer.setAudioSource(audioSource);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.typeFile.delete();
    audioPlayer.dispose();
    
  }
}

class WaveFormPainter extends CustomPainter{

  final List<int> waveForm;
  double currentPos;
  Duration duration;
  WaveFormPainter({required this.waveForm,required this.currentPos,required this.duration});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color=Colors.black..style=PaintingStyle.fill;
    final highlight = Paint()..color=Colors.green..style=PaintingStyle.fill..strokeWidth=3;
    double centerY = size.width/3;
    for(int i=0;i<waveForm.length-255;i=i+255 ){
    double x1 = (i/waveForm.length)*size.width;
    double x2 =((i+255)/waveForm.length)*size.width;
    double y1 = centerY - (waveForm[i]/255)*centerY;
    double y2 = centerY - (waveForm[i+255]/255)*centerY;
    double segmentTime = (i/waveForm.length)*duration.inSeconds;
    if(segmentTime <= currentPos && segmentTime + (300/waveForm.length)*duration.inSeconds>=currentPos){

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), highlight);
    }
    else{
    canvas.drawLine(Offset(x1,y1),Offset(x2,y2), paint);
    }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate)=>true;
}
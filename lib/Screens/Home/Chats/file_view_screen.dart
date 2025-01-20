import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'file_display_screen.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:http/http.dart' as http;




class FileViewDialog extends StatefulWidget {
  String fileType;
  String fileUrl;
  String audioTime;
 
   FileViewDialog({super.key,required this.fileType,required this.fileUrl,required this.audioTime});

  @override
  State<FileViewDialog> createState() => _FileViewDialogState();
}

class _FileViewDialogState extends State<FileViewDialog> {
   Timer? timer;
  VideoPlayerController? _controller;
final audioPlayer = AudioPlayer();
late Future<List<int>> audioFreqList;
List<int> aud=[];

 File typeFile=File('audioFile');
bool isVolume = true;
bool isPlay=true;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.fileType=='video'){
      _controller=VideoPlayerController.networkUrl(Uri.parse(widget.fileUrl))..initialize()..addListener((){
        setState(() {
          
        });
      })..play();
    }
    else{
     
     audioFreqList= getAudio();
       
      setState(() {
        audioPlayer.play();
        audioPlayer.setLoopMode(LoopMode.all);
      });

      
    }
    
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child:Scaffold(
       backgroundColor: Colors.transparent,
       body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        child: widget.fileType=='video'?AspectRatio(
          aspectRatio: 1,
          child: Stack(
                children: [
                
                  _controller!.value.isInitialized==false || _controller!.value.isBuffering==true? Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width*0.9,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(color: Colors.blue,)): Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width*0.9,
                    child: VideoPlayer(_controller!)),
                  Align(alignment: Alignment.bottomRight,child: Row(
                    children: [
                      Text('${0.00}',style: TextStyle(color: Colors.green,fontSize: 18,),),
                      const SizedBox(width: 10,),
                      Icon(isVolume?Icons.volume_off:Icons.volume_down,color: Colors.black,size: 35,),
                      const SizedBox(width: 5,),
                      Center(child: IconButton(onPressed: (){
                               if(_controller!.value.isPlaying){
                                _controller!.pause();
                                isPlay=false;
                                setState(() {
                                  
                                });
                               }
                               else{
                                _controller!.play();
                                isPlay=true;
                                setState(() {
                                  
                                });
                               }     
                      }, icon: Icon(isPlay?Icons.pause_circle:Icons.play_circle,color: Colors.blue,size: 40,)),),
                      const SizedBox(height: 10,),
                      Container(
                      
                        width: MediaQuery.of(context).size.width*0.3,
                        child: Slider(value: _controller!.value.position.inSeconds.toDouble(),min: 0.0,max: _controller!.value.duration.inSeconds.toDouble(), onChanged:(value){
                          setState(() {
                        
                            _controller!.seekTo(Duration(seconds: value.toInt()));
                            
                          });
                          
                        },),
                      ),
                      const SizedBox(width: 10,),
                      Text('${_controller!.value.position.inMinutes}:${_controller!.value.position.inSeconds%60}/${_controller!.value.duration.inMinutes}:${_controller!.value.duration.inSeconds%60}'),
             
                    ],
                  ),),
                  IconButton(onPressed: (){

                  }, icon: Icon(Icons.download,color: Colors.blue,size: 40,)),
                ],
              ),
        ):Container(
            height: 200,
            color: Colors.transparent,
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

                // StreamBuilder(stream:typeFile!=null? typeFile!.openRead().skip(60):Stream.empty(), builder: (context,snapshot){
                //   if(snapshot.hasData){

                //   return StreamBuilder<Duration?>(
                //     stream: audioPlayer.positionStream,
                //     builder: (context, snapshots) {
                //       if(snapshot.hasData && audioPlayer.duration !=null){
                //       return Container(
                //         height: 150,
                //         width: MediaQuery.of(context).size.width*0.9,
                //         child: CustomPaint(painter: WaveFormPainter(waveForm: snapshot.data!,duration: audioPlayer.duration!,currentPos:snapshots.hasData? snapshots.data!.inSeconds.toDouble():0.0 ),
                        
                //         size: Size(100,100),
                //         ),
                //       );
                //     }
                //     else{
                //       return Center(child: CircularProgressIndicator(color: Colors.blue,),);
                //     }
                //     }
                  
                //   );
                //   }
                //   else{
                //     return Center(child: CircularProgressIndicator(color: Colors.blue,),);
                //   }
                // }),
                
                // Container(child: PolygonWaveform(samples: audioFreqDoubleList.skip(10000).toList(), height: 150, width: MediaQuery.of(context).size.width*0.9),),
                
                // Container(height: 100,width: MediaQuery.of(context).size.width*0.8,child: audioPlayer.position==Duration(seconds:0)?Center(child: CircularProgressIndicator(color: Colors.blue,)):Container()),

                // Container(
                //   height: 200,
                //  child: FutureBuilder(future: audioFreqList, builder: (context,snapshot){
                    
                //   timer=  Timer.periodic(Duration(seconds: 1), (timer){
                //     if(mounted){
                //        setState(() {
                         
                //        });
                //     }
                //     });

                  
                //     return Container(
                //       height: 150,
                //       width: MediaQuery.of(context).size.width*0.9,
                //       child: CustomPaint(
                //         painter: wavePaint(waveForm:snapshot.data!=null? snapshot.data!.skip(255).toList():aud,currentPos:audioPlayer.position.inSeconds.toDouble(),duration:audioPlayer.duration!=null?audioPlayer.duration!:Duration(seconds: 0) ),
                //       ),
                //     );
                //   }),
  
                // ),
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
                       Text('Audio-${widget.audioTime.substring(widget.audioTime.length-4)}',style: TextStyle(fontWeight: FontWeight.bold),),
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
                  ),
                  
                   IconButton(onPressed: (){

                  }, icon: Icon(Icons.download,color: Colors.blue,size: 40,)),
                
                
              ],
            ),
           ),
        
       ),
    ));
  }
  Future<List<int>> getAudio() async{
    final AudioSource source = AudioSource.uri(Uri.parse(widget.fileUrl));
      audioPlayer.setAudioSource(source);
     final response = await http.get(Uri.parse(widget.fileUrl));
     List<int> doubFreqList = [];
     if(response.statusCode==200){
      
        doubFreqList = response.bodyBytes;
        
     }

     return doubFreqList;
    
  }
  @override
  void dispose() {
    if(timer!=null){
      timer!.cancel();
    }
    
    // TODO: implement dispose
    super.dispose();
    if(_controller!=null){
      _controller!.dispose();
    }
    
    audioPlayer.dispose();
  
  }
}

class wavePaint extends CustomPainter{
  final List<int> waveForm;
  double currentPos;
  Duration duration;
  wavePaint({required this.waveForm,required this.currentPos,required this.duration});

  @override
  void paint(Canvas canvas,Size size ){
   final paint = Paint()..color=Colors.blueAccent..style=PaintingStyle.fill;
   final highlight = Paint()..color=Colors.green..style=PaintingStyle.fill;
   double width = size.width/waveForm.length;
   for(int i=0;i<waveForm.length;i++){
    double height = (waveForm[i]/255)*size.height;
    canvas.drawRect(Rect.fromLTWH(i*width, size.height-height, width, height), paint);

    canvas.drawLine(Offset(currentPos*width, 0), Offset(currentPos*width,size.height), highlight);
   }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate)=>true;

}


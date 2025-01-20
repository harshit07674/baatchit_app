import 'package:baatchit/Screens/Profile/profilescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:baatchit/Screens/OTP/otpscreen.dart';
import 'package:baatchit/Widgets/uihelper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController=TextEditingController();
   TextEditingController userNameController=TextEditingController();
    TextEditingController passController=TextEditingController();
    bool isPassCorrect=true;
  final user = FirebaseAuth.instance;
  String verification = '';
  String selectedcountry="India";
  String selectedcountryCode='+91';
  List<String>countries=[
    "India",
    "USA",
    "Japan",
    "Italy",
    "Germany"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 80,
          ),
          Center(
            child: UiHelper.CustomText(
                text: "Enter your phone number",
                height: 20,
                color: Color(0XFF00A884),
                fontweight: FontWeight.bold),
          ),
          SizedBox(
            height: 30,
          ),
          UiHelper.CustomText(
              text: "WhatsApp will need to verify your phone", height: 16),
          UiHelper.CustomText(
              text: "number. Carrier charges may apply.", height: 16),
          UiHelper.CustomText(
              text: " What’s my number?", height: 16, color: Color(0XFF00A884)),
          SizedBox(height: 50,),
         Padding(
           padding: const EdgeInsets.only(left: 60,right: 60),
           child: DropdownButtonFormField(items: countries.map((String country){
             return DropdownMenuItem(child: Text(country),value: country,);
           }).toList(), onChanged: (newvalue){
             setState(() {
               selectedcountry=newvalue!;
                switch(selectedcountry){
                  case 'India':
                  selectedcountryCode='+91';
                  break;
                  case 'USA':
                  selectedcountryCode='+1';
                  break;
                  case 'Japan':
                  selectedcountryCode='+81';
                  break;
                  case 'Italy':
                  selectedcountryCode='+39';
                  break;
                  case 'Germany':
                  selectedcountryCode='+49';
                  break;
                }
             });
           },value: selectedcountry,decoration: InputDecoration(
             enabledBorder: UnderlineInputBorder(
               borderSide: BorderSide(color: Color(0XFF00A884))
             ),
             focusedBorder: UnderlineInputBorder(
               borderSide: BorderSide(color: Color(0XFF00A884))
             )
           ),),
         ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                child: Text(selectedcountryCode,style: TextStyle(fontSize: 16,color: Colors.green,fontWeight: FontWeight.bold),),
              ),
              SizedBox(width: 10,),
              SizedBox(
                width: 250,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: phoneController,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0XFF00A884))
                    )
                  ),
                ),
              ),

            ],
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Text('userName',style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),),
            const SizedBox(width: 10,),
             SizedBox(
                width: 250,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: userNameController,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0XFF00A884))
                    )
                  ),
                ),
              )
          ],),
                    Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Text('Password',style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),),
            const SizedBox(width: 10,),
             SizedBox(
                width: 250,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: passController,
                  onChanged: (val){
                    RegExp passExp = RegExp(r'^(?=.*[0-9])(?=.*[A-Z])(?=.*[!@#$%&]).{7,}$');
                   if(!passExp.hasMatch(val)){
                    setState(() {
                      isPassCorrect=false;
                    });
                   }
                   else{
                    setState(() {
                      isPassCorrect=true;
                    });
                   }
                  },
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0XFF00A884))
                    )
                  ),
                ),
              )
          ],),
         isPassCorrect?Container():Text('Password should be more than 6 letters and should have atleast one uppercase letter, one number, one special characetr',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),overflow: TextOverflow.clip,),
        ],
      ),
      floatingActionButton: UiHelper.CustomButton(callback: (){
        login(phoneController.text.toString());
      }, buttonname: "Next"),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  login(String phonenumber){
    if(phonenumber=="" || userNameController.text.isEmpty || passController.text.isEmpty){
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all details",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),backgroundColor: Colors.red,));
    }
    else{
      if(isPassCorrect==false){
        return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Validation for password failed",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),backgroundColor: Colors.red,));
      }
      else{
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(userName: userNameController.text,password: passController.text,phoneNumber: phoneController.text,phoneCode:selectedcountryCode)));
    }
    }
  }
  void verifyUser(String phoneNumber){
    user.verifyPhoneNumber(
      phoneNumber: '+91'+phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async{
      await user.signInWithCredential(credential);
    }, verificationFailed: (FirebaseAuthException e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sorry, error occurreed: $e',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),backgroundColor: Colors.red,));
    }, codeSent: (String verifyId,int? resendToken){
      verification=verifyId;
    }, codeAutoRetrievalTimeout:(String verify){
      verification=verify;
    });
  }
  
}

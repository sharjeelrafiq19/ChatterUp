import 'dart:developer';
import 'dart:io';

import 'package:chatter_up/api/apis.dart';
import 'package:chatter_up/helper/dialogs.dart';
import 'package:chatter_up/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  /// handling Google LogIn Button Click
  _handleGoogleBtnClick(){
    //for showing progress bar
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(context);

      if(user != null){
        log("\nUser: ${user.user}");
        log("\nUserAdditionalInfo: ${user.additionalUserInfo}");

        if((await APIs.userExists())) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }else{
          await APIs.createUser().then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          });
        }


      }

    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try{
      // check user is connected with internet or not
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    }catch(error){
      log("\n_signInWith Google: $error");
      Dialogs.showSnackbar(context, "Something went wrong (Check Internet!)");
      return null;
    }
  }

  ///SignOut function
  // _signOut() async{
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Welcome to ChatterUp"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 250,
              child: Image.asset("assets/images/chat.png"),
            ),
          ),
          const SizedBox(
            height: 250,
          ),
          InkWell(
            onTap: (){
              _handleGoogleBtnClick();
            },
            child: Container(
              height: MediaQuery.of(context).size.height *  .06,
              width: MediaQuery.of(context).size.width *  .9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Color(0xff2c462b),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/google.png"),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "SignIn with Google",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ],
      ),

      // Stack(
      //   children: [
      //     Positioned(
      //       top: MediaQuery.of(context).size.height *  .15,
      //       left: MediaQuery.of(context).size.width *  .25,
      //       width: MediaQuery.of(context).size.width *  .5,
      //       child: Image.asset("assets/images/chat.png"),
      //     ),
      //
      //   ],
      // ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_rider_app/main.dart';
import 'package:uber_rider_app/screens/main_screen.dart';
import 'package:uber_rider_app/screens/register_screen.dart';
import 'package:uber_rider_app/widgets/progress_dialog.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  static const String idScreen = "login";
  LoginScreen({super.key});

  TextEditingController emailTextEditingcontroller = TextEditingController();
  TextEditingController passwordTextEditingcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 35.0,
              ),
              const Image(
                image: AssetImage("assets/images/logo.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 15.0),
              const Text(
                "Login as a Rider",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: emailTextEditingcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: passwordTextEditingcontroller,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 400,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow, // Background color
                        ),
                        onPressed: () {
                          if (!emailTextEditingcontroller.text.contains('@')) {
                            Fluttertoast.showToast(
                                msg: "Email Address is not valid.");
                          } else if (passwordTextEditingcontroller.text.length <
                              6) {
                            Fluttertoast.showToast(
                                msg: "Password is mandatory.");
                          } else {
                            loginAndAuthenticateUser(context);
                          }
                        },
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: "Brand Bold",
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegisterScreen.idScreen, (route) => false);
                  },
                  child: const Text("Do not have an Account ? Register Here."))
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "Authenticating, Please wait ...",
      ),
    );

    UserCredential firebaseUserCredential = await _firebaseAuth
        .signInWithEmailAndPassword(
            email: emailTextEditingcontroller.text,
            password: passwordTextEditingcontroller.text)
        // ignore: body_might_complete_normally_catch_error
        .catchError((errorMsg) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: + $errorMsg");
    });
    User? user = firebaseUserCredential.user;

    if (user != null) {
      // Save Info User To Databse
      userRef.child(user.uid).once().then((value) => (DataSnapshot snap) {
            if (snap.value != null) {
              // ignore: use_build_context_synchronously
              Navigator.pushNamedAndRemoveUntil(
                  context, MainScreen.idScreen, (route) => false);
              Fluttertoast.showToast(msg: "You are logged-in now.");
            } else {
              Navigator.pop(context);
              _firebaseAuth.signOut();
              Fluttertoast.showToast(
                  msg:
                      "No record exists for this user. Please create new account.");
            }
          });
    } else {
      // Error Occured
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error occurec, can be log-in.");
    }
  }
}

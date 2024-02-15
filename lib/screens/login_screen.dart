import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    const TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 400,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow, // Background color
                        ),
                        onPressed: () {},
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
                  onPressed: () {},
                  child: const Text("Do not have an Account ? Register Here."))
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider_app/assistants/request_assistant.dart';

import '../data_handler/app_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation!.placeName ?? "";
    pickUpTextEditingController.text = placeAddress;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 215.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 25, top: 25, right: 25, bottom: 20),
              child: Column(
                children: [
                  const SizedBox(height: 5.0),
                  Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back)),
                      const Center(
                        child: Text(
                          'Set Drop Off',
                          style:
                              TextStyle(fontSize: 18, fontFamily: "Brand-Bold"),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/pickicon.png",
                        height: 20.0,
                        width: 20.0,
                      ),
                      const SizedBox(width: 18.0),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextField(
                            controller: pickUpTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Pick Up Location",
                              fillColor: Colors.grey[400],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 11.0, top: 8.0, bottom: 8.0),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/desticon.png",
                        height: 20.0,
                        width: 20.0,
                      ),
                      const SizedBox(width: 18.0),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextField(
                            onChanged: (val) {
                              findPlace(val);
                            },
                            controller: dropOffTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Where to ?",
                              fillColor: Colors.grey[400],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 11.0, top: 8.0, bottom: 8.0),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyA5uLRfE1Ea9ie7ei9PGHJT43VQVm-IQCM&sessiontoken=1234567890&components=country:dz";
      var res = await RequestAssistant.getRequest(autoCompleteUrl);
      if (res == "failed") {
        return;
      }
      log("PLaces Predictions Response :: $res");
    }
  }
}

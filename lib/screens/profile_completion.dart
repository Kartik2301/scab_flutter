// Copyright (c) 2019 Souvik Biswas

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scab_flutter/screens/journey_plan_screen.dart';
import 'package:scab_flutter/resources/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'login_page.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

final _firestore = Firestore.instance;
class _FirstScreenState extends State<FirstScreen> {

  String phoneNumber,gender;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue[100], Colors.blue[400]],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(
                  imageUrl,
                ),
                radius: 60,
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: 40),
              Text(
                'NAME',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              Text(
                name,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'EMAIL',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              Text(
                email,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
              Text('PhoneNumber'),
              TextField(
                onChanged: (value){
                  phoneNumber=value;
                },
              ),
              Text('Gender'),
              TextField(
                onChanged: (value){
                  gender=value;
                },
              ),
              SizedBox(height: 40),
              RaisedButton(
                child: Text('Submit Details'),
                onPressed: (){
                  registerUserInDatabase();
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context)=> JourneyPlanScreen(mUid: uid,),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void registerUserInDatabase() async {
    await _firestore.collection('users').document(uid).setData({
      'imageUrl': imageUrl,
      'fullName': name,
      'phoneNumber': phoneNumber,
      'email':email,
      'gender': gender,
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(kSPuid, uid);
    preferences.setBool(kSPfirstLogIn, false);
  }
}

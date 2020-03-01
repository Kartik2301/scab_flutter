import 'package:flutter/material.dart';
import 'package:scab_flutter/resources/objects.dart';
import 'package:scab_flutter/resources/sign_in.dart';

import 'login_page.dart';

class ShowProfile extends StatelessWidget {
  final User _user;
  ShowProfile(this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(color: Colors.green, fontSize: 30),

        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,

      ),
      body: new Container(
          child: Column(
        children: <Widget>[
          SizedBox(
            height: 15.0,
          ),
          Center(
            child: CircleAvatar(
              radius: 40.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(_user.imageUrl),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(_user.fullName),
          SizedBox(
            height: 25.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              Column(
                children: <Widget>[
                  Text(
                    'Age',
                  ),
                  Text(
                    '27 years',
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(
                    'Email',
                  ),
                  Text(
                    _user.email,
                  ),
                ],
              ),
              SizedBox(
                width: 10.0,
              ),
            ],
          ),
          SizedBox(
            height: 40.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(
                width: 45.0,
              ),
              Text(
                'Gender',
              ),
              SizedBox(
                width: 30.0,
              ),
              Image.asset('images/gender.jpeg',
                width: 80,
                height: 80,
              ),
              SizedBox(
              ),
              Image.asset(
                'images/fk.jpeg',
                width: 100,
                height: 80,
              ),
              SizedBox(
                width: 20.0,
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
            child: TextField(
              style: TextStyle(
                  fontSize: 22.0,
                  color: Color(0xFFbdc6cf),
                  backgroundColor: Colors.grey),
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.display1,
                labelText: 'Enter phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          RaisedButton(
            textColor: Colors.white,
            color: Colors.green,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
            ),
            onPressed: () {
              print('hello');
            },
            padding: const EdgeInsets.all(8.0),
            child: new Text(
              "Save",
            ),
          ),
        ],
      )),
    );
  }
}


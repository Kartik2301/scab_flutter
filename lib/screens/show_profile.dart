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
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CircleAvatar(
              child: Image.network(_user.imageUrl),
            ),
            Center(child: Text(_user.fullName)),
            Center(child: Text(_user.email)),
            Center(child: Text(_user.gender)),
            Center(child: Text(_user.phoneNumber)),
            Center(child: Text(_user.rollNo)),
            RaisedButton(
              child: Text('SIGN OUT'),
              onPressed: (){
                signOutGoogle();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {return LoginPage();}), ModalRoute.withName('/'));
              },
            )
          ],
        ),
      ),
    );
  }
}

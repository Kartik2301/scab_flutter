import 'package:flutter/material.dart';
import 'package:scab_flutter/screens/journey_plan_screen.dart';
import 'package:scab_flutter/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

bool _firstLogIn;
String _uid;

class _IntroScreenState extends State<IntroScreen> {

  void checkLogin() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _uid= preferences.getString(kSPuid) ?? "UIDNotFound";
    _firstLogIn = preferences.getBool(kSPfirstLogIn) ?? true;
//    print('Done');
//    print(_uid);
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context)=>_firstLogIn?LoginPage():JourneyPlanScreen(mUid: _uid,),
              ));
            },
            child: Text('Skip')
        ),
      ),
    );
  }
}

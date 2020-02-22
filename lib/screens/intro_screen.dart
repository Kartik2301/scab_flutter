import 'package:flutter/material.dart';
import 'package:scab_flutter/screens/journey_plan_screen.dart';
import 'package:scab_flutter/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

bool _firstLogIn;
String _uid;

class IntroScreen extends StatefulWidget {
  static String getUid()=>_uid;
  static void setUid(String uid){
    _uid= uid;
  }

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {

  void checkLogin() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _uid= preferences.getString(kSPuid) ?? "UIDNotFound";
    _firstLogIn = preferences.getBool(kSPfirstLogIn) ?? true;
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }
  @override
  Widget build(BuildContext context) {
    final controller = PageController(
      initialPage: 0,
    );
    return Scaffold(
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 10,
            child: PageView(
              controller: controller,
              children: <Widget>[
                IntroImage('introscreen1.png'),
                IntroImage('introscreen1.png'),
                IntroImage('introscreen1.png'),
              ],
            ),
          ),
          Center(
            child: RaisedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>_firstLogIn?LoginPage():JourneyPlanScreen(mUid: _uid,),
                  ));
                },
                child: Text('Skip')
            ),
          ),
        ],
      ),
    );
  }
}

class IntroImage extends StatelessWidget {
  final String introImage;
  IntroImage(this.introImage);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
            child: Image(
              image: AssetImage('images/$introImage'),
              height: 400,
              width: 400,
            ),
          )),
    );
  }
}
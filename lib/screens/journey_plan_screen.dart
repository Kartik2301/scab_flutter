
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scab_flutter/constants.dart';
import 'package:scab_flutter/resources/sign_in.dart';
import 'package:scab_flutter/resources/objects.dart';
import 'package:scab_flutter/screens/show_profile.dart';

User _user = User();
bool loadingUserData;

class JourneyPlanScreen extends StatefulWidget {
  static String id = 'journey_plan';

  final String mUid;
  JourneyPlanScreen({this.mUid});

  @override
  _JourneyPlanScreenState createState() => _JourneyPlanScreenState();
}

class _JourneyPlanScreenState extends State<JourneyPlanScreen> {



  void getUserProfileData() async {
    final _firestore= Firestore.instance;
    var document = await _firestore.collection('users').document(widget.mUid).get();
    print(document.data);

    _user.uid=widget.mUid;
    _user.imageUrl=document.data['imageUrl'];
    _user.fullName= document.data['fullName'];
    _user.email=document.data['email'];
    _user.gender=document.data['gender'];
    _user.phoneNumber=document.data['phoneNumber'];
    _user.rollNo=_user.email.substring(0,_user.email.indexOf('@')).toUpperCase();

    setState(() {
      loadingUserData=false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadingUserData=true;
    getUserProfileData();
  }

  @override
  Widget build(BuildContext context) {
    print(uid);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: <Widget>[
              RaisedButton(
                color: loadingUserData?Colors.grey:kThemeColor,
                child: Text('SHOW PROFILE'),
                onPressed: (){
                  loadingUserData? print('Please Wait'):Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowProfile(_user)));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.card_giftcard,
                    size: 40,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    'Search Ride',
                    style: TextStyle(
                        color: kThemeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 30),
                  )
                ],
              ),
              Text(
                'From',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Text(
                'To',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit an App'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }
}
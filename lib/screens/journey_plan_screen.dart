
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scab_flutter/constants.dart';
import 'package:scab_flutter/resources/objects.dart';
import 'package:scab_flutter/screens/intro_screen.dart';
import 'package:scab_flutter/screens/room_search_screen.dart';
import 'package:scab_flutter/screens/show_profile.dart';

User _user = User();
bool loadingUserData;
String _source,_destination;
int hour,minutes;

class JourneyPlanScreen extends StatefulWidget {
  static String id = 'journey_plan';
  static String username;
  final String mUid;
  JourneyPlanScreen({this.mUid});

  @override
  _JourneyPlanScreenState createState() => _JourneyPlanScreenState();
}

class _JourneyPlanScreenState extends State<JourneyPlanScreen> {

  void fetchUserProfileData() async {
    final _firestore= Firestore.instance;
    var document = await _firestore.collection('users').document(widget.mUid).get();
    print(document.data);

    _user.uid=widget.mUid;
    _user.imageUrl=document.data['imageUrl'];
    _user.fullName= document.data['fullName'];
    JourneyPlanScreen.username=_user.fullName.substring(0,_user.fullName.indexOf(' '));
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
    fetchUserProfileData();
    IntroScreen.getUid()??IntroScreen.setUid(_user.uid);//Setting uid to IntroScreen during first Login
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
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
                get_sourceDropDownButton(),
                Text(
                  'To',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                get_destinationDropDownButton(),
                Row(
                  children: <Widget>[
                    Text('TIME'),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: getHourPicker(),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: getMinutePicker(),
                      ),
                    ),
                  ],
                ),
                RaisedButton(
                  child: Text('Search Rides'),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RoomSearch(user: _user,source: _source,destination: _destination,)));
                  },
                ),
              ],

            ),
          ),
        ),
      ),
    );
  }

  DropdownButton<String> get_sourceDropDownButton() {
    List <DropdownMenuItem<String>> dropDownMenuItems = [];
    for (String event in placesList) {
      var newItem = DropdownMenuItem(
        child: Text(event),
        value: event,
      );
      dropDownMenuItems.add(newItem);
    }
    return DropdownButton<String>(
        value: _source,
        items: dropDownMenuItems,
        onChanged: (value){
          setState(() {
            _source = value;
            print(_source);
          });
        });
  }
  DropdownButton<String> get_destinationDropDownButton() {
    List <DropdownMenuItem<String>> dropDownMenuItems = [];
    for (String event in placesList) {
      var newItem = DropdownMenuItem(
        child: Text(event),
        value: event,
      );
      dropDownMenuItems.add(newItem);
    }
    return DropdownButton<String>(
        value: _destination,
        items: dropDownMenuItems,
        onChanged: (value){
          setState(() {
            _destination = value;
            print(_destination);
          });
        });
  }

  CupertinoPicker getHourPicker()
  {
    List<Text> currencyList = [];
    for(int currency in hourList)
    {
      currencyList.add(Text(currency.toString()));
    }

    return CupertinoPicker(
      backgroundColor: Colors.white,
      itemExtent: 32.0,
      children: currencyList,
      onSelectedItemChanged: (value){
        hour= int.parse(currencyList[value].data);
        print(hour);
      },
    );
  }

  CupertinoPicker getMinutePicker()
  {
    List<Text> currencyList = [];
    for(int currency in minuteList)
    {
      currencyList.add(Text(currency.toString()));
    }

    return CupertinoPicker(
      backgroundColor: Colors.white,
      itemExtent: 32.0,
      children: currencyList,
      onSelectedItemChanged: (value){
        minutes= int.parse(currencyList[value].data);
        print(minutes);
      },
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
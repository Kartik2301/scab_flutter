
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scab_flutter/constants.dart';
import 'package:scab_flutter/resources/objects.dart';
import 'package:scab_flutter/screens/intro_screen.dart';
import 'package:scab_flutter/screens/room_search_screen.dart';
import 'package:scab_flutter/screens/show_profile.dart';
import 'package:scab_flutter/resources/components.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

User _user = User();
bool loadingUserData;
String _source,_destination;
int hour,minutes;
String _time = "Time not set";

class JourneyPlanScreen extends StatefulWidget {
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
    Fluttertoast.showToast(msg: 'UID: ${IntroScreen.getUid()}');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.only(left: 8,right: 8,top: 32,bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TitleRow(
                    title: 'Create a Ride',
                    onBackPress: (){
                      showDialog(context: context,
                      builder: (context)=>showExitDialog(context));
                },),
                SizedBox(height: 80,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      height: 140,
                      image: AssetImage('images/maps_markers.png'),
                    ),
                    SizedBox(width: 40,),
                    Column(
                      children: <Widget>[
                        Container(
                          color: Colors.grey[100],
                          child: getSourceDropDownButton(),
                        ),
                        SizedBox(height: 50,),
                        Container(
                          color: Colors.grey[100],
                          child: getDestinationDropDownButton(),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 70.0, top: 16.0, bottom: 16.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 4.0,
                        onPressed: () {
                          DatePicker.showTimePicker(context,
                              theme: DatePickerTheme(
                                containerHeight: 210.0,
                              ),
                              showTitleActions: true, onConfirm: (time) {
                                print('confirm $time');
                                _time = '${time.hour} : ${time.minute} : ${time.second}';
                                setState(() {});
                              }, currentTime: DateTime.now(), locale: LocaleType.en);
                          setState(() {});
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.access_time,
                                          size: 18.0,
                                          color: Colors.teal,
                                        ),
                                        Text(
                                          " $_time",
                                          style: TextStyle(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left : 8.0),
                                child: Text(
                                  "  Change",
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                BottomLargeButton(
                  text: 'Show Profile',
                  onPressed: (){
                    loadingUserData? print('Please Wait'):Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowProfile(_user)));
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                BottomLargeButton(
                    text: 'Search Ride',
                    onPressed: () {
                      if(_source==null||_destination==null) {
                          Fluttertoast.showToast(
                              msg: "Please Enter the Ride Details"
                          );
                        }
                      else {
                        Navigator.push(context, MaterialPageRoute
                          (builder: (context) => RoomSearch(user: _user,
                          source: _source,
                          destination: _destination,)));
                      }
                    }),
              ],

            ),
          ),
        ),
      ),
    );
  }

  DropdownButton<String> getSourceDropDownButton() {
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
  DropdownButton<String> getDestinationDropDownButton() {
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
      builder: (context) => showExitDialog(context),
    )) ?? false;
  }

  AlertDialog showExitDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Exit',style: TextStyle(fontSize: 30),),
      content: Text('Are you sure you don\'t want to share the ride?'),
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
    );
  }
}

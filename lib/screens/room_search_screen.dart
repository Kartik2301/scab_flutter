import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scab_flutter/resources/objects.dart';
import 'package:scab_flutter/screens/in_room_screen.dart';
import 'package:scab_flutter/screens/journey_plan_screen.dart';

final _firestore = Firestore.instance;
String _source,_destination;
User _user;

class RoomSearch extends StatefulWidget {
  final User user;
  RoomSearch({@required this.user});
  @override
  _RoomSearchState createState() => _RoomSearchState();
}

class _RoomSearchState extends State<RoomSearch> {

  void fetchRooms() async{

  }

  void createRoom()async {
    //TODO: Implement Firebase Room Creation
    DocumentReference ref = await _firestore.collection(_source)
        .add({
      'destination': _destination,
      'source':_source,
      'numberOfMembers': 1,
      'time':Timestamp.now(),
      'journeyTime':1131322323,
      'isVacant':true,
    });
    print(ref.documentID);
    _firestore.collection(_source).document(ref.documentID).updateData({'roomId': ref.documentID});


    _firestore.collection(_source).document(ref.documentID).collection('members').document(_user.uid).setData({
      //'uid':_user.uid,
      'fullName':_user.fullName,
      'rollNo':_user.rollNo,
      'imageUrl':_user.imageUrl,
      'gender':_user.gender,
      'phoneNumber':_user.phoneNumber,
    });

    Navigator.push(context, MaterialPageRoute(builder: (context)=>InRoom()));
  }

  @override
  void initState() {
    super.initState();
    _user=widget.user;
    _source=source;
    _destination=destination;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: RaisedButton(
            child: Text('CREATE'),
            onPressed: createRoom,
          ),
        ),
    );
  }
}

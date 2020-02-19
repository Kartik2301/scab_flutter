import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scab_flutter/constants.dart';
import 'package:scab_flutter/resources/components.dart';
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

  List<RoomCard> roomsList = [];

  void fetchRooms() async{

    await for(var snapshot in _firestore.collection(_source).orderBy('time', descending: true).snapshots())
    {
      List<RoomCard> updatedRoomsList = [];
      for(var message in snapshot.documents)
      {
        String source,destination,roomOwner,ownerRoll,roomId;

        source = message.data['source']??'Source Unavailable';
        destination =message.data['destination']??'Destination Unavailable';
        roomOwner = "John Wick";
        ownerRoll = "IEC2018069";
        roomId = message.data['roomId']??'Room Id Unavailable';

        updatedRoomsList.add(RoomCard(source: source,destination:destination,ownerRoll: ownerRoll,roomOwner:roomOwner,roomId: roomId,));
      }
      setState(() {
        roomsList = updatedRoomsList;
      });
    }
  }

  void createRoom()async {
    //TODO: Implement Firebase Room Creation
    String roomId;
    DocumentReference ref = await _firestore.collection(_source)
        .add({
      'destination': _destination,
      'source':_source,
      'numberOfMembers': 1,
      'time':Timestamp.now(),
      'journeyTime':1131322323,
      'isVacant':true,
    });
    roomId=ref.documentID;
    print(roomId);
    _firestore.collection(_source).document(roomId).updateData({'roomId': roomId});

    _firestore.collection(_source).document(roomId).collection('members').document(_user.uid).setData({
      //'uid':_user.uid,
      'fullName':_user.fullName,
      'rollNo':_user.rollNo,
      'imageUrl':_user.imageUrl,
      'gender':_user.gender,
      'phoneNumber':_user.phoneNumber,
    });

    Navigator.push(context, MaterialPageRoute(builder: (context)=>InRoom(roomId: roomId,source: _source,destination: _destination,)));
  }

  @override
  void initState() {
    super.initState();
    _user=widget.user;
    _source=source;
    _destination=destination;
    fetchRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kThemeColor,
        title: Text('Search Rooms'),
      ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: roomsList,
              ),
            ),
            Container(
              child: RaisedButton(
                child: Text('CREATE'),
                onPressed: createRoom,
              ),
            ),
          ],
        ),
    );
  }
}

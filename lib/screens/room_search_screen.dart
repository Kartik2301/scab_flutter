import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scab_flutter/constants.dart';
import 'package:scab_flutter/resources/components.dart';
import 'package:scab_flutter/resources/objects.dart';
import 'package:scab_flutter/screens/in_room_screen.dart';
import 'package:scab_flutter/screens/intro_screen.dart';

final _firestore = Firestore.instance;
String _source,_destination;
User _user;

class RoomSearch extends StatefulWidget {
  final User user;
  final String source,destination;
  RoomSearch({@required this.user,this.source,this.destination});
  @override
  _RoomSearchState createState() => _RoomSearchState();
}

class _RoomSearchState extends State<RoomSearch> {

  List<RoomCard> roomsList = [];
  List<RoomCard> myRoomsList = [];

  void fetchRequestedRoomsStatus () async
  {
    Future<Room> fetchRoomDetails(String roomId) async
    {
      Room room = Room();
      try{
        var document = await _firestore.collection('places').document(_source).collection('rooms').document(roomId).get();
        print(document.data);
        room.source = document.data['source']??'Source Unavailable';
        room.destination =document.data['destination']??'Destination Unavailable';
        room.journeyTime = document.data['journeyTime']??'NULL';
      }
      catch(e)
      {
        print('RequestedRoomId not found from searched source');
      }
      return room;
    }

    String roomId,status;

    await for(var snapshot in _firestore.collection('users')
        .document(IntroScreen.getUid()).collection('myRooms').orderBy('createdAt',descending: true ).snapshots())
    {
      List<RoomCard> lMyRoomsList = [];
      for(var message in snapshot.documents)
      {
        roomId = message.data['roomId'];
        status = message.data['status'];

        Room fetchedRoom = await fetchRoomDetails(roomId);
        lMyRoomsList.add(
            RoomCard(
              source: fetchedRoom.source,
              destination: fetchedRoom.destination,
              joiningStatus: status,
              roomId: roomId,
            ));

        setState(() {
          myRoomsList=lMyRoomsList;
        });
      }
    }

  }

  void fetchRooms() async{
    await for(var snapshot in _firestore.collection('places').document(_source).collection('rooms').orderBy('createdAt', descending: true).snapshots())
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

        updatedRoomsList.add(RoomCard(source: source,destination:destination,ownerRoll: ownerRoll,roomOwner:roomOwner,roomId: roomId,joiningStatus: kJoinRequest,));
      }
      setState(() {
        roomsList = updatedRoomsList;
      });
    }
  }

  void createRoom()async{
    //TODO: Implement Firebase Room Creation
    String roomId;
    DocumentReference ref = await _firestore.collection('places').document(_source).collection('rooms')
        .add({
      'destination': _destination,
      'source':_source,
      'numberOfMembers': 1,
      'createdAt':Timestamp.now(),
      'journeyTime':1131322323,
      'isVacant':true,
    });
    roomId=ref.documentID;
    print(roomId);
    _firestore.collection('places').document(_source).collection('rooms').document(roomId).updateData({'roomId': roomId});
    _firestore.collection('places').document(_source).collection('rooms').document(roomId).updateData({
      'member1': IntroScreen.getUid(),
    });

    Navigator.push(context, MaterialPageRoute(builder: (context)=>InRoom(roomId: roomId,source: _source,destination: _destination,isOwner: true,introduce: true,)));
  }

  @override
  void initState() {
    super.initState();
    _user=widget.user;
    _source=widget.source;
    _destination=widget.destination;
    fetchRooms();
    fetchRequestedRoomsStatus();
  }

  bool allRooms=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 32,horizontal: 8),
          child: Column(
            children: <Widget>[
              TitleRow(title: 'Rides',),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32,vertical: 16),
                      child: Text('All Rooms'),
                    ),
                    onPressed: (){
                      setState(() {
                        allRooms=true;
                      });
                    },
                  ),
                  RaisedButton(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32,vertical: 16),
                      child: Text('My Rooms'),
                    ),
                    onPressed: (){
                      setState(() {
                        allRooms=false;
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allRooms?roomsList.length:myRoomsList.length,
                  itemBuilder: (context,index){
                    return allRooms?roomsList[index]:myRoomsList[index];
                  },
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
        ),
    );
  }
}

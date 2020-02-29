import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:scab_flutter/constants.dart';
import 'package:scab_flutter/resources/components.dart';
import 'package:scab_flutter/resources/objects.dart';
import 'package:scab_flutter/screens/in_room_screen.dart';
import 'package:scab_flutter/screens/intro_screen.dart';

final _firestore = Firestore.instance;
String _source,_destination;
bool roomsLoading;

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
    Future<Room> fetchRoomDetails(String roomId) async {
      Room room = Room();
      try{
        var document = await _firestore.collection('places').document(_source).collection('rooms').document(roomId).get();
        print(document.data);
        room.source = document.data['source']??'Source Unavailable';
        room.destination =document.data['destination']??'Destination Unavailable';
        room.journeyTime = document.data['journeyTime']??'NULL';
      }
      catch(e) {
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
        String source,destination,roomId;
        int numberOfMembers,journeyTime;
        String member1;

        source = message.data['source']??'Source Unavailable';
        destination =message.data['destination']??'Destination Unavailable';
        roomId = message.data['roomId']??'Room Id Unavailable';
        numberOfMembers = message.data['numberOfMembers'];
        journeyTime = message.data['journeyTime'];
        member1 = message.data['member1'];

        updatedRoomsList.add(RoomCard(source: source,destination:destination,roomId: roomId,
          joiningStatus: kJoinRequest,numberOfMembers: numberOfMembers,member1: member1,journeyTime: journeyTime,));
      }
      setState(() {
        roomsList = updatedRoomsList;
        roomsLoading=false;
      });
    }
  }

  void createRoom()async{
    //Implement Room Creation in Firebase
    String roomId;
    DocumentReference ref = await _firestore.collection('places').document(_source).collection('rooms')
        .add({
      'destination': _destination,
      'source':_source,
      'numberOfMembers': 1,
      'createdAt':Timestamp.now(),
      'journeyTime':1131322323,
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
    _source=widget.source;
    _destination=widget.destination;
    roomsLoading=true;
    fetchRooms();
    fetchRequestedRoomsStatus();
  }

  bool allRooms=true;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: roomsLoading,
      child: Scaffold(
          body: Padding(
            padding: EdgeInsets.only(left: 8,right: 8,top: 32,bottom: 8),
            child: Column(
              children: <Widget>[
                TitleRow(title: 'Rides',),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                          child: Text('All Rooms',style: TextStyle(fontSize: 18),),
                        ),
                        onPressed: (){
                          setState(() {
                            allRooms=true;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                          child: Text('My Rooms',style: TextStyle(fontSize: 18),),
                        ),
                        onPressed: (){
                          setState(() {
                            allRooms=false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      itemCount: allRooms?roomsList.length:myRoomsList.length,
                      itemBuilder: (context,index){
                        return allRooms?roomsList[index]:myRoomsList[index];
                      },
                    ),
                  ),
                ),
                BottomLargeButton(
                  text: 'Create your own room',
                  onPressed: createRoom,
                ),
              ],
            ),
          ),
      ),
    );
  }
}

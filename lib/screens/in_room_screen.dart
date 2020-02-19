import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scab_flutter/constants.dart';
import 'package:scab_flutter/resources/components.dart';

final _firestore = Firestore.instance;

class InRoom extends StatefulWidget {
  final String roomId,source,destination;

  InRoom({@required this.roomId,@required this.source,@required this.destination});

  @override
  _InRoomState createState() => _InRoomState();
}

class _InRoomState extends State<InRoom> {

  List<RequestCard> requestsList=[
    RequestCard(
      requestedUID: "FAKE",
      source: 'JAHANUM',
      roomId: 'FUCK',
      status: 'FAKE',
    ),
  ];

  void fetchRequests () async
  {
    await for(var snapshot in _firestore.collection(widget.source).document(widget.roomId).collection('requests').snapshots())
    {
      List<RequestCard> updatedRoomsList = [RequestCard(
        requestedUID: "FAKE",
        source: 'JAHANUM',
        roomId: 'FUCK',
        status: 'FAKE',
      ),];
      for(var message in snapshot.documents)
      {
        String requestedUid,status;
        requestedUid = message.data['uid']??"UID NOT FOUND";
        status = message.data['status']??'STATUS NOT FOUND';

        updatedRoomsList.add(RequestCard(requestedUID: requestedUid,roomId: widget.roomId,source: widget.source,status: status));
      }
      setState(() {
        requestsList = updatedRoomsList;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('In Room'),backgroundColor: kThemeColor,),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(widget.source),
                Text(widget.destination),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: requestsList,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scab_flutter/constants.dart';
import 'package:scab_flutter/screens/in_room_screen.dart';
import 'package:scab_flutter/screens/intro_screen.dart';

import 'objects.dart';

class DetailInputWidget extends StatelessWidget {
  final String detailName;

  DetailInputWidget({this.detailName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
      child: TextField(
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kThemeColor, width: 3.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          hintText: detailName,
        ),
      ),
    );
  }
}


class RoomCard extends StatelessWidget {
  final String source,destination,roomOwner,ownerRoll,roomId,joiningStatus;
  RoomCard({this.source,this.destination,this.roomOwner,this.ownerRoll,this.roomId,this.joiningStatus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 5,
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Room Owner',style: TextStyle(fontSize: 18),),
                Column(
                  children: <Widget>[
                    Text(roomOwner??'NA',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(ownerRoll??'NA'),
                    )
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(source??'NA',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                //TODO:Icons to be added here
                Text(destination??'NA',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
              ],
            ),
            //TODO: Time Row Here
            RaisedButton(
              color: joiningStatus==kJoinRequest?Colors.black:(joiningStatus==kConfirmJoin?kThemeColor:Colors.red),
              child: Text(joiningStatus??kJoinRequest,style: TextStyle(color: Colors.white),),
              onPressed: (){

                if(joiningStatus==kJoinRequest) {
                  //TODO:Send Joining Requests
                  Firestore.instance.collection(source).document(roomId)
                      .collection('requests').document(IntroScreen.getUid())
                      .setData({
                    'status': kPendingRequest,
                    'uid': IntroScreen.getUid(),
                    'createdAt': Timestamp.now(),
                  });
                  Firestore.instance.collection('users').document(
                      IntroScreen.getUid()).collection('myRooms').document(
                      roomId).setData({
                    'status': kPendingRequest,
                    'roomId': roomId,
                    'createdAt': Timestamp.now(),
                  });
                }
                else if(joiningStatus==kConfirmJoin)
                  {
                    print(roomId);
                    Firestore.instance.collection(source).document(roomId)
                        .updateData({
                    'newUser': IntroScreen.getUid(),
                    });
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>InRoom(
                      source: source,
                      destination: destination,
                      isOwner: false,
                      roomId: roomId,
                    )));
                  }
                else{
                  //Do nothing when requests is pending
                  }
              },
            ),
          ],
        ),
      ),
    );
  }
}



class RequestCard extends StatelessWidget {
  final String source,roomId,requestedUID,status;
  RequestCard({@required this.source,@required this.roomId,@ required this.requestedUID,this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Card(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Request Card'),
                Text(requestedUID),
                Text(status),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                  child: Text('Accept'),
                  onPressed: (){
                    //TODO: Implement Accept Functionality
                    Firestore.instance.collection(source).document(roomId).collection('requests').document(requestedUID).updateData({
                      'status': kConfirmJoin,
                    });
                    Firestore.instance.collection('users').document(requestedUID).collection('myRooms').document(roomId).updateData({
                      'status': kConfirmJoin,
                    });
                  },
                ),
                RaisedButton(
                  child: Text('Decline'),
                  onPressed: (){
                    //TODO: Implement Reject Functionality
                    Firestore.instance.collection(source).document(roomId).collection('requests').document(requestedUID).updateData({
                      'status': kRejectedRequest,
                    });
                    Firestore.instance.collection('users').document(requestedUID).collection('myRooms').document(roomId).updateData({
                      'status': kRejectedRequest,
                    });
                  },
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}

class MemberCard extends StatelessWidget {

  final User _user;
  final String designation;
  MemberCard(this._user,{this.designation});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        color: Colors.grey[300],
        child: ListTile(
          leading: CircleAvatar(
            child: Image.network(_user.imageUrl??'https://avatars2.githubusercontent.com/u/46641571?s=400&u=f758fa76ddf23047aa50eeef64d34bea49933850&v=4'),
          ),
          title: Text(_user.fullName),
          subtitle: Text(designation),
          trailing: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(_user.rollNo),
                Text(_user.gender)
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;


  MessageBubble({this.text, this.sender,this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              color: isMe?Colors.black54:Colors.white,
              fontSize: 12.0,
            ),
          ),
          Material(
            elevation: 5.0,
            borderRadius: isMe?BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)
            ):BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)
            ),
            color: isMe?Colors.lightBlueAccent:Colors.white,
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20.0,
                  vertical: 10.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe? Colors.white:Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

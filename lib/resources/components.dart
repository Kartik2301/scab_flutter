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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),

        ),
    ),
      elevation: 5,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16,right: 16,top: 16),
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
                    Expanded(child: Text(source??'NA',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
                    Image(
                      height: 20,
                      image: AssetImage('images/horizontal_markers.png',),
                    ),
                    Expanded(child: Text(destination??'NA',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),))
                  ],
                ),
                Padding(
                  padding:EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Time: 4:00 PM',style: TextStyle(fontSize: 10),),
                      Text('4 hrs left',style: TextStyle(fontSize: 10,color: kRed,fontWeight: FontWeight.bold),),
                      Text('Members: 1',style: TextStyle(fontSize: 10),)
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: joiningStatus==kJoinRequest?Colors.black:(joiningStatus==kConfirmJoin?kThemeColor:kRed),
                borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              )
            ),
            width: double.infinity,
            child: FlatButton(
              color: joiningStatus==kJoinRequest?Colors.black:(joiningStatus==kConfirmJoin?kThemeColor:kRed),
              child: Text(joiningStatus??kJoinRequest,style: TextStyle(color: Colors.white),),
              onPressed: (){
                if(joiningStatus==kJoinRequest) {
                  //Send Joining Requests
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
                  //Add new member in the room
                  Firestore.instance.collection(source).document(roomId).get().then((value){
                    print('value + ${value.data}');
                    int numberOfMembers = value.data['numberOfMembers'];
                    if(numberOfMembers<4)
                    {
                      Firestore.instance.collection(source).document(roomId).updateData({
                        'member${numberOfMembers+1}': IntroScreen.getUid(),
                        'numberOfMembers': numberOfMembers+1,
                      });

                      Navigator.push(context, MaterialPageRoute(builder: (context)=>InRoom(
                        source: source,
                        destination: destination,
                        isOwner: false,
                        roomId: roomId,
                        introduce: true,
                      )));
                    }
                    else
                    {
                      //TODO: Show a toast that room is full now
                    }
                  });
                }
                else{
                  //TODO: Show a Toast
                }
              },
            ),
          )
        ],
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
                    //Implement Accept Functionality
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

class CustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  CustomButton({@required this.text,this.onPressed});
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
        color: kThemeColor,
        onPressed:onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 16),
          child: Text(text,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
        )
    );
  }
}


class BottomLargeButton extends StatelessWidget {

  final String text;
  final Function onPressed;
  BottomLargeButton({this.text,this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      child: RaisedButton(
        color: kThemeColor,
        child: Text(text,style: TextStyle(fontSize: 20,color: Colors.white),),
        onPressed: onPressed,
      ),
    );
  }
}

class TitleRow extends StatelessWidget {
  final String title;
  TitleRow({this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.keyboard_backspace,color: kThemeColor,size: 35,),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Image(
            height: 35,
            image: AssetImage('images/scab_small_logo.png'),
          ),
        ),
        Text(title,style: TextStyle(color: kThemeColor,fontSize: 28,fontWeight: FontWeight.bold),),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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


class RoomCard extends StatefulWidget {
  final String source,destination,member1,roomId,joiningStatus;
  final int numberOfMembers,journeyTime;

  RoomCard({this.source,this.destination,this.roomId,this.joiningStatus,this.numberOfMembers,this.member1,this.journeyTime});

  @override
  _RoomCardState createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  User owner;
  bool loadingOwner;

  Future<User> fetchMemberProfile(String uid) async{
    User _user = User();
    final _firestore= Firestore.instance;
    var document = await _firestore.collection('users').document(uid).get();
    _user.uid=uid;
    _user.imageUrl=document.data['imageUrl'];
    _user.fullName= document.data['fullName'];
    _user.email=document.data['email'];
    _user.gender=document.data['gender'];
    _user.phoneNumber=document.data['phoneNumber'];
    _user.rollNo=_user.email.substring(0,_user.email.indexOf('@')).toUpperCase();
    return _user;
  }

  void fetchOwnerDetails() async{
    owner= await fetchMemberProfile(widget.member1);
    setState(() {
      loadingOwner=false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadingOwner=true;
    fetchOwnerDetails();
  }
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        loadingOwner?Container(width: 150,height:20,color: Colors.grey[100],)
                            :Text(owner.fullName,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: loadingOwner?Container(width: 100,height:20,color: Colors.grey[100],)
                                  : Text(owner.rollNo,style: TextStyle(fontSize: 12),),
                            ),
                            SizedBox(width: 20,),
                            loadingOwner?Container(width: 10,height:20,color: Colors.grey[100],):
                              Text('Male',style: TextStyle(fontSize: 12),)
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(child: Text(widget.source??'NA',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)),
                    Image(
                      height: 20,
                      image: AssetImage('images/horizontal_markers.png',),
                    ),
                    Expanded(child: Text(widget.destination??'NA',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),))
                  ],
                ),
                Padding(
                  padding:EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Time: 4:00 PM',style: TextStyle(fontSize: 10),),
                      Text('4 hrs left',style: TextStyle(fontSize: 10,color: kRed,fontWeight: FontWeight.bold),),
                      Text('Members: ${widget.numberOfMembers}',style: TextStyle(fontSize: 10),)
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: widget.joiningStatus==kJoinRequest?Colors.black:(widget.joiningStatus==kConfirmJoin?kThemeColor:kRed),
                borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              )
            ),
            width: double.infinity,
            child: FlatButton(
              color: widget.joiningStatus==kJoinRequest?Colors.black:(widget.joiningStatus==kConfirmJoin?kThemeColor:kRed),
              child: Text(widget.joiningStatus??kJoinRequest,style: TextStyle(color: Colors.white),),
              onPressed: (){
                if(widget.joiningStatus==kJoinRequest) {
                  //Send Joining Requests
                  Firestore.instance.collection('places').document(widget.source).collection('rooms').document(widget.roomId)
                      .collection('requests').document(IntroScreen.getUid())
                      .setData({
                    'status': kPendingRequest,
                    'uid': IntroScreen.getUid(),
                    'createdAt': Timestamp.now(),
                  });
                  Firestore.instance.collection('users').document(
                      IntroScreen.getUid()).collection('myRooms').document(
                      widget.roomId).setData({
                    'status': kPendingRequest,
                    'roomId': widget.roomId,
                    'createdAt': Timestamp.now(),
                  });
                }
                else if(widget.joiningStatus==kConfirmJoin)
                {
                  //Add new member in the room
                  Firestore.instance.collection('places').document(widget.source).collection('rooms').document(widget.roomId).get().then((value){
                    print('value + ${value.data}');
                    int numberOfMembers = value.data['numberOfMembers'];
                    if(numberOfMembers<4) {
                      Firestore.instance.collection('places').document(widget.source).collection('rooms').document(widget.roomId).updateData({
                        'member${numberOfMembers+1}': IntroScreen.getUid(),
                        'numberOfMembers': numberOfMembers+1,
                      });

                      Navigator.push(context, MaterialPageRoute(builder: (context)=>InRoom(
                        source: widget.source,
                        destination: widget.destination,
                        isOwner: false,
                        roomId: widget.roomId,
                        introduce: true,
                      )));
                    }
                    else {
                      Fluttertoast.showToast(msg: 'Sorry, the room is full now!');
                    }
                  });
                }
                else{
                  Fluttertoast.showToast(msg: 'Already Requested! Please wait while the owner accepts the request');
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
                    Firestore.instance.collection('places').document(source).collection('rooms').document(roomId).collection('requests').document(requestedUID).updateData({
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
                    //Implement Reject Functionality
                    Firestore.instance.collection('places').document(source).collection('rooms').document(roomId).collection('requests').document(requestedUID).updateData({
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
  final String type;

  MessageBubble({this.text, this.sender,this.isMe,this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:type==kMessageType?(isMe?CrossAxisAlignment.end:CrossAxisAlignment.start):CrossAxisAlignment.center,
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
            borderRadius: type==kMessageType?(isMe?BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)
            ):BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)
            )):BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            color: type==kMessageType?(isMe?kThemeColor:Colors.white):Colors.black,
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20.0,
                  vertical: 10.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: type==kMessageType?(isMe? Colors.white:Colors.black):Colors.white,
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
  final Color colour;
  final double width;
  BottomLargeButton({this.text,this.onPressed,this.colour,this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width??double.infinity,
      height: 60,
      child: RaisedButton(
        color: colour??kThemeColor,
        child: Text(text,style: TextStyle(fontSize: 20,color: Colors.white),),
        onPressed: onPressed,
      ),
    );
  }
}

class TitleRow extends StatelessWidget {
  final String title;
  final Function onBackPress;
  TitleRow({this.title,this.onBackPress});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        FlatButton(
          onPressed: onBackPress??(){
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.keyboard_backspace,
            color: kThemeColor,size: 35,),
        ),
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

class User{//Total 7 Fields
  String uid;
//5 Data Items stored in database
  String imageUrl;
  String fullName;
  String email;
  String gender;
  String phoneNumber;

  String rollNo;
}

class Room{//Total 7 Fields
  //All stored in Database
  String roomId;
  //time denotes room creation time
  String createdAt;
  String source;
  String destination;
  String journeyTime;
  int numberOfMembers;
  bool isVacant;
}
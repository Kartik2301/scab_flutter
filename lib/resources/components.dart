import 'package:flutter/material.dart';
import 'package:scab_flutter/constants.dart';

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
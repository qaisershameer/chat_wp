import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';

  // constant Global Parameters Project Level
  final AuthService _authService = AuthService();

  // GET CURRENT USER ID
  String kUserId = _authService.getCurrentUser()!.uid;
  // String kUserId = 'CAKf9wMH4IfA58EmzDVJlMjLuRh2';
  String? kUserEmail = _authService.getCurrentUser()!.email;

  String kCPV = 'CP';
  String kCRV = 'CR';
  String kJV = 'JV';

  String kCash = 'CASH';
  String kBank = 'BANK';

  String kApiUrl = 'http://10.0.2.2:8000/api/';

  String kToken = '1|IldYuTylZ8HIV4MIRqRCrh6IFewUIOBgDQFMIMSja2aa25d7';

  Map<String, String> kHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $kToken', // Replace with your actual token
  };

  final DateTime stDate = DateTime(DateTime.now().year, 7, 1);
  final String kStartDate = DateFormat('dd-MMM-yyyy').format(stDate);

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
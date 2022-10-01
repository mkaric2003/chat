import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  ChatScreen({
    required this.peerAvatar,
    required this.peerId,
    required this.peerNickname,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

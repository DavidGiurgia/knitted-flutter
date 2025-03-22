import 'package:flutter/material.dart';


class FindFriendsSection extends StatefulWidget {
  const FindFriendsSection({super.key});

  @override
  State<FindFriendsSection> createState() => _FindFriendsSectionState();
}

class _FindFriendsSectionState extends State<FindFriendsSection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Discover accounts"),),);
  }
}
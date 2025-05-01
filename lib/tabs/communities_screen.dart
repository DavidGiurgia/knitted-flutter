import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Text("Comunities"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(TablerIcons.search)),
          IconButton(onPressed: () {}, icon: Icon(TablerIcons.dots_vertical)),
        ],
      ), body: Center(
              child: Text(
                'Coming soon!',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            ),
    );
  }
}

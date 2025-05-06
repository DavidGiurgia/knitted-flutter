import 'package:flutter/material.dart';

class ReorderCommunities extends StatefulWidget {
  const ReorderCommunities({super.key});

  @override
  State<ReorderCommunities> createState() => _ReorderCommunitiesState();
}

class _ReorderCommunitiesState extends State<ReorderCommunities> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder Communities'),
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          // Implementați logica de reordonare aici
          // De exemplu, actualizați ordinea comunităților în baza de date
        },
        children: List.generate(10, (index) {
          return ListTile(
            key: ValueKey(index),
            leading: const Icon(Icons.drag_handle),
            title: Text('Community $index'),
          );
        }),
      ),
    );
  }
}
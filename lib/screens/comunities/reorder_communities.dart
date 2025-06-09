import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/providers/community_provider.dart';

class ReorderCommunities extends ConsumerStatefulWidget {
  const ReorderCommunities({super.key});

  @override
  ConsumerState<ReorderCommunities> createState() => _ReorderCommunitiesState();
}

class _ReorderCommunitiesState extends ConsumerState<ReorderCommunities> {
  late List<Community> _reorderedCommunities;

  @override
  void initState() {
    super.initState();
    // Initialize with current communities
    final communityState = ref.read(CommunityNotifier.provider);
    _reorderedCommunities = List.from(communityState.joinedCommunities);
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(CommunityNotifier.provider);
    
    // Update our local list if the provider data changes
    if (_reorderedCommunities.length != communityState.joinedCommunities.length) {
      _reorderedCommunities = List.from(communityState.joinedCommunities);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder Communities'),
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.check),
            onPressed: _saveNewOrder,
          ),
        ],
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Community item = _reorderedCommunities.removeAt(oldIndex);
            _reorderedCommunities.insert(newIndex, item);
          });
        },
        children: _reorderedCommunities.map((community) {
          return ListTile(
            key: ValueKey(community.id),
            leading: const Icon(Icons.drag_handle),
            title: Text(community.name),
            subtitle: Text("${community.members.length} members"),
           
          );
        }).toList(),
      ),
    );
  }

  Future<void> _saveNewOrder() async {
    try {
      // Update the order in the backend
      // await ref.read(CommunityNotifier.provider.notifier)
      //     .updateCommunitiesOrder(_reorderedCommunities);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Community order saved successfully')),
        );
        Navigator.of(context).pop(); // Close the reorder screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save order: ${e.toString()}')),
        );
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/screens/comunities/create_community.dart';
import 'package:zic_flutter/screens/comunities/your_communities.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';

class CommunitiesScreen extends ConsumerStatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  ConsumerState<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends ConsumerState<CommunitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar clasic, simplu, non-scrollabil.
      appBar: AppBar(
        automaticallyImplyLeading: false, // Nu arată săgeata înapoi implicit
        title: Text('Communities'),

        actions: [
          
          // Icon pentru căutare
          IconButton(
            onPressed: () {
              // TODO: Implementează funcționalitatea de căutare
              CustomToast.show(context, 'Search functionality coming soon!');
            },
            icon: const Icon(TablerIcons.search),
          ),
          PopupMenuButton(
            itemBuilder:
                (context) => [
                   PopupMenuItem(
                    value: 'create',
                    child: Row(
                      children: [
                        const Icon(TablerIcons.plus, size: 20),
                        const SizedBox(width: 8),
                        Text('Create new community'),
                      ],
                    ),
                    onTap: () => _createNewCommunity(context),
                  ),
                  const PopupMenuItem(
                    value: 'discover',
                    child: Row(
                      children: [
                        Icon(TablerIcons.compass, size: 20),
                        SizedBox(width: 8),
                        Text('Discover communities'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body:
          const YourCommunities(), // YourCommunities gestionează acum întreaga listă scrollabilă
    );
  }
}

// Funcție pentru navigarea la ecranul de creare a unei noi comunități.
void _createNewCommunity(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CreateCommunity()),
  );
}

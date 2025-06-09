import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/providers/community_provider.dart';
import 'package:zic_flutter/screens/comunities/community_profile.dart';
import 'package:zic_flutter/screens/comunities/create_community.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';

// --- YourCommunities ---
// Această clasă rămâne un ConsumerStatefulWidget deoarece interacționează direct cu Riverpod.
// A fost modificată pentru a include butonul de creare a comunității și mesajele de stare.
class YourCommunities extends ConsumerStatefulWidget {
  const YourCommunities({super.key});

  @override
  ConsumerState<YourCommunities> createState() => _YourCommunitiesState();
}

class _YourCommunitiesState extends ConsumerState<YourCommunities> {
  @override
  void initState() {
    super.initState();
    // Programăm încărcarea datelor după ce primul frame este desenat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // Funcție asincronă pentru a încărca datele comunităților utilizatorului.
  Future<void> _loadData() async {
    try {
      await ref.read(CommunityNotifier.provider.notifier).loadUserCommunities();
    } catch (e) {
      // Afișează toast pentru eroare în loc de widget dedicat.
      if (mounted) {
        // Verifică dacă widget-ul este încă montat înainte de a afișa toast-ul
        CustomToast.show(
          context,
          'Failed to load communities: ${e.toString()}',
        );
      }
    }
  }

  // Funcție pentru navigarea la ecranul de creare a unei noi comunități.
  void _createNewCommunity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCommunity()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ascultă starea comunităților de la provider-ul Riverpod.
    final communityState = ref.watch(CommunityNotifier.provider);

    // Ascultă modificările stării și afișează un toast la eroare.
    // Această metodă este sigură pentru a apela ScaffoldMessenger.of(context)
    // deoarece este declanșată de o modificare a stării într-un context activ.
    ref.listen<CommunityState>(CommunityNotifier.provider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        // Afișează doar erori noi
        if (mounted) {
          // Verifică dacă widget-ul este încă montat pentru siguranță suplimentară
          CustomToast.show(
            context,
            'Failed to load communities: ${next.error!}',
          );
        }
      }
    });

    return RefreshIndicator(
      // RefreshIndicator acum înconjoară conținutul scrollabil
      onRefresh: _loadData,
      child: _buildContentBasedOnState(
        communityState,
      ), // Helper pentru a returna widget-ul principal de conținut
    );
  }

  // Construiește conținutul principal al comunităților în funcție de stare.
  Widget _buildContentBasedOnState(CommunityState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Indicator de încărcare
    }

    final communities = state.joinedCommunities;
    List<Widget> listItems = [];

    // Adaugă butonul "Create New Community" ca un element de listă.
     listItems.add(_buildCreateCommunityItem(context));
    // // Adaugă butonul "Discover More Communities".
    // listItems.add(_buildDiscoverCommunityItem(context));

    // Adaugă mesajul de stare goală dacă nu există comunități (în afară de cardul de creare).
    if (communities.isEmpty) {
      listItems.add(_buildEmptyStateMessage());
    } else {
      // Adaugă toate cardurile comunităților.
      listItems.addAll(
        communities.map((community) => _buildCommunityItem(community)).toList(),
      );
    }

    return ListView.builder(
      // AlwaysScrollableScrollPhysics asigură că lista este întotdeauna scrollabilă,
      // ceea ce este necesar pentru ca RefreshIndicator să funcționeze chiar și cu puține elemente.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Ajustează padding-ul listei
      itemCount: listItems.length,
      itemBuilder:
          (context, index) =>
              listItems[index], // Afișează fiecare element din lista construită
    );
  }

  // Construiește elementul de listă pentru butonul "Create New Community" cu aspect simplu.
  Widget _buildCreateCommunityItem(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _createNewCommunity(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    AppTheme.isDark(context)
                        ? AppTheme.grey800
                        : AppTheme.grey100,
                borderRadius: BorderRadius.circular(
                  32,
                ), // Colțuri ușor rotunjite
              ),
              child: const Icon(TablerIcons.plus, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('New community')),
            //const Icon(TablerIcons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  // Construiește un element de listă pentru fiecare comunitate existentă cu aspect simplu.
  Widget _buildCommunityItem(Community community) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _navigateToCommunity(community),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Avatarul comunității (patrat cu colturile rotunjite)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    AppTheme.isDark(context)
                        ? AppTheme.grey800
                        : AppTheme.grey100,
                borderRadius: BorderRadius.circular(12), // Colțuri rotunjite
                image:
                    community.bannerUrl.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(community.bannerUrl),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  community.bannerUrl.isEmpty
                      ? const Icon(TablerIcons.users_group, size: 24)
                      : null,
            ),
            const SizedBox(width: 12), // Spațiu între avatar și detalii
            // Detaliile comunității (nume și număr de membri sub)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(community.name),
                  const SizedBox(height: 2),
                  Text(
                    '${community.members.length} members',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Indicator de acces (săgeată)
            //const Icon(TablerIcons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  // Widget pentru afișarea unui mesaj de stare goală (când nu sunt comunități).
  Widget _buildEmptyStateMessage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.users_group, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'You haven\'t joined any communities yet',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Funcție pentru navigarea la o comunitate specifică.
  void _navigateToCommunity(Community community) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommunityProfileScreen(community: community,)),
    );
  }
}

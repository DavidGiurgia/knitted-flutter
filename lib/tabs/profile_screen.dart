import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/create_post.dart';
import 'package:zic_flutter/screens/settings/settings_and_activity.dart';
import 'package:zic_flutter/screens/shared/edit_profile.dart';
import 'package:zic_flutter/screens/friends/friends_section.dart';
import 'package:zic_flutter/screens/shared/profile_photo.dart';
import 'package:zic_flutter/screens/shared/profile_tabs.dart';
import 'package:zic_flutter/utils/silver_appbar_delegate.dart';
import 'package:zic_flutter/widgets/button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // Changed length to 3
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user data available')),
      );
    }
    final friends = ref.watch(friendsProvider(null)).value;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePost()),
              );
            },
            icon: Icon(
              TablerIcons.lock,
              color: AppTheme.foregroundColor(context),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePost()),
              );
            },
            icon: Icon(
              TablerIcons.square_rounded_plus,
              color: AppTheme.foregroundColor(context),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsAndActivity(),
                ),
              );
            },
            icon: Icon(
              TablerIcons.settings,
              color: AppTheme.foregroundColor(context),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(friendsProvider(null));
          ref.invalidate(userProvider);
          ref.invalidate(creatorPostsProvider(user.id));
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start, // Align items to the start
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  user.fullname,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (user.bio.isNotEmpty)
                                  Text(
                                    user.bio,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                FriendsSection(user: user),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${friends?.length ?? 0} friends",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              AppTheme.isDark(context)
                                                  ? Colors.grey.shade600
                                                  : Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16), // Add some spacing
                          GestureDetector(
                            onTap: () {
                              if (user.avatarUrl != "") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProfilePhoto(
                                          imagePath: user.avatarUrl,
                                        ),
                                  ),
                                );
                              }
                            },
                            child: AdvancedAvatar(
                              size: 64,
                              image: NetworkImage(user.avatarUrl),
                              autoTextSize: true,
                              name: user.fullname,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.isDark(context)
                                        ? AppTheme.grey200
                                        : AppTheme.grey800,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.isDark(context)
                                        ? AppTheme.grey800
                                        : AppTheme.grey200,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      CustomButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        text: 'Edit Profile',
                        isFullWidth: true,
                        type: ButtonType.bordered,
                        size: ButtonSize.small,
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverAppBarDelegate(
                  tabBar: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.grey.withValues(alpha: 0.1),
                    indicatorColor: AppTheme.foregroundColor(context),
                    labelColor: AppTheme.foregroundColor(context),
                    unselectedLabelColor: Colors.grey,
                    //indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: 'Posts'),
                      Tab(text: 'Media'),
                      Tab(text: 'Replies'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: ProfileTabs(userId: user.id, tabController: _tabController),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/screens/notifications/notifications_section.dart';
import 'package:zic_flutter/screens/post/create_post.dart';
import 'package:zic_flutter/widgets/button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String assetName = 'lib/assets/images/ZIC-logo.svg';
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SvgPicture.asset(
          assetName,
          semanticsLabel: 'ZiC Logo',
          //width: 32,
          height: 26,
        ),
        actions: [
          CustomButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePost()),
              );
            },
            isIconOnly: true,
            heroIcon: HeroIcons.plus,
            type: ButtonType.light,
            size: ButtonSize.large,
          ),
          CustomButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsSection()),
              );
            },
            isIconOnly: true,
            heroIcon: HeroIcons.bell,
            size: ButtonSize.large,
          ),
        ],
      ),
    );
  }
}

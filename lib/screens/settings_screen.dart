import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _launchURL(String url) async => await canLaunchUrl(Uri.parse(url))
      ? await launchUrl(Uri.parse(url))
      : throw 'Could not launch $url';

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'SETTINGS',
            style: theme.textTheme.bodyMedium,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                _buildListTile(
                    "Github Repository",
                    "View the source code on Github, contribute, or report issues.",
                    FontAwesomeIcons.github, () {
                  _launchURL("https://github.com/SushiiReboot/Nothing-Clock");
                }),
                _buildListTile(
                    "Language", "English", FontAwesomeIcons.globe, () {}),
              ],
            ),
          ),
        ));
  }

  ListTile _buildListTile(
      String title, String? subtitleText, IconData? icon, Function()? onTap) {
    return ListTile(
      onTap: onTap,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title.toUpperCase()),
          const SizedBox(
            width: 15,
          ),
          Icon(
            icon,
            size: 15,
          )
        ],
      ),
      subtitle: subtitleText != null
          ? Text(subtitleText,
              style: const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing: const Padding(
        padding: EdgeInsets.only(left: 15.0),
        child: Icon(
          Icons.arrow_forward_ios,
          size: 15,
        ),
      ),
    );
  }
}

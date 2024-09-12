import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nothing_clock/providers/theme_provider.dart';
import 'package:nothing_clock/widgets/switch_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _launchURL(String url) async => await canLaunchUrl(Uri.parse(url))
      ? await launchUrl(Uri.parse(url))
      : throw 'Could not launch $url';

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    final themeProvider = Provider.of<ThemeProvider>(context);

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
                    context,
                    "Github Repository",
                    "View the source code on Github, contribute, or report issues.",
                    FontAwesomeIcons.github, () {
                  _launchURL("https://github.com/SushiiReboot/Nothing-Clock");
                }, null),
                _buildListTile(context, "Language", "English",
                    FontAwesomeIcons.globe, () {}, null),
                _buildListTile(context, "Theme", themeProvider.currentTheme,
                    FontAwesomeIcons.palette, () {
                  themeProvider.toggleTheme();
                },
                    SwitchButton(
                      activeTrackColor: theme.colorScheme.tertiary,
                      activeColor: theme.colorScheme.primary,
                      inactiveTrackColor: Colors.white.withOpacity(0.15),
                      inactiveThumbColor: theme.colorScheme.onSurface,
                      onChanged: () {
                        themeProvider.toggleTheme();
                      },
                      defaultValue: !themeProvider.isDarkMode,
                    )),
              ],
            ),
          ),
        ));
  }

  ListTile _buildListTile(
      BuildContext context,
      String title,
      String? subtitleText,
      IconData? icon,
      Function()? onTap,
      Widget? trailing) {
    return ListTile(
      onTap: trailing == null ? onTap : null,
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
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface))
          : null,
      trailing: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: trailing ??
            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
            ),
      ),
    );
  }
}

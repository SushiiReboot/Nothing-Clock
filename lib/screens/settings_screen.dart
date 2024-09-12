import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                _buildListTile("Github Repository",
                    "View the source code on Github, contribute, or report issues."),
                _buildListTile("Language", "English"),
              ],
            ),
          ),
        ));
  }

  ListTile _buildListTile(String title, String? subtitleText) {
    return ListTile(
      onTap: () {
        print("TAPPED");
      },
      title: Text(title.toUpperCase()),
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

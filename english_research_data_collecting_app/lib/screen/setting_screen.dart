import 'package:english_research_data_collecting_app/globals.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingsList(
        sections: [
          SettingsSection(
            // title: Text('Common'),
            tiles: <SettingsTile>[
              // SettingsTile.navigation(
              //   leading: Icon(Icons.language),
              //   title: Text('Language'),
              //   value: Text('English'),
              // ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    GlobalVar.isEditorMode = value;
                  });
                },
                initialValue: GlobalVar.isEditorMode,
                leading: const Icon(Icons.developer_mode),
                title: const Text('Enable editor mode'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

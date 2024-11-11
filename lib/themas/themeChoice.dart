// ignore_for_file: file_names

import 'package:flutter/cupertino.dart'
    show
        BuildContext,
        Column,
        CupertinoIcons,
        EdgeInsets,
        Icon,
        Padding,
        State,
        StatefulWidget,
        Text,
        Widget;
import 'package:flutter/material.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: depend_on_referenced_packages

class ThemeChoice extends StatefulWidget {
  const ThemeChoice({super.key});
  @override
  ThemeChoiceState createState() => ThemeChoiceState();
}

class ThemeChoiceState extends State<ThemeChoice> {
  late ThemeMode _selectedThemeMode;

  final List _options = [
    {
      "title": 'Sistema(auto)',
      "value": ThemeMode.system,
      "subtitle": "Se adapta automaticamente.",
      "icon": CupertinoIcons.device_phone_portrait
    },
    {
      "title": 'Claro',
      "value": ThemeMode.light,
      "subtitle": "Fondos mas  claros",
      "icon": CupertinoIcons.sun_max
    },
    {
      "title": 'Oscuro',
      "value": ThemeMode.dark,
      "subtitle": "Fondos mas  oscuros",
      "icon": CupertinoIcons.moon_fill
    }
  ];

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _createOptions(ThemeModeNotifier themeModeNotifier) {
    List<Widget> widgets = [];
    for (Map option in _options) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 17),
          child: ListTileTheme(
            dense: true,
            contentPadding: const EdgeInsets.all(2),
            style: ListTileStyle.drawer,
            child: RadioListTile(
              activeColor: Colors.blue,
              value: option['value'],
              secondary: Icon(option['icon']),
              groupValue: _selectedThemeMode,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                child: Text(option['title'],
                    style:
                        const TextStyle(fontFamily: "Poppins", fontSize: 18)),
              ),
              onChanged: (mode) {
                _setSelectedThemeMode(mode, themeModeNotifier);
              },
              selected: _selectedThemeMode == option['value'],
              subtitle: Text(option['subtitle']),
              toggleable: true,
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  void _setSelectedThemeMode(
      ThemeMode mode, ThemeModeNotifier themeModeNotifier) async {
    themeModeNotifier.setThemeMode(mode);
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', mode.index);
    setState(() {
      _selectedThemeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // init radios with current themeMode
    final themeModeNotifier = Provider.of<ThemeModeNotifier>(context);
    setState(() {
      _selectedThemeMode = themeModeNotifier.getThemeMode();
    });
    // build the Widget
    return Column(
      children: <Widget>[
        Column(
          children: _createOptions(themeModeNotifier),
        ),
      ],
    );
  }
}

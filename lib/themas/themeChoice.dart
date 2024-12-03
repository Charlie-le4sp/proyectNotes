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
  String _selectedCustomTheme = 'default';

  final List _options = [
    {
      "title": 'Tema del Sistema',
      "value": ThemeMode.system,
      "customTheme": 'default',
      "subtitle": "Se adapta automáticamente entre claro y oscuro",
      "icon": CupertinoIcons.device_phone_portrait
    },
    {
      "title": 'Tema Claro',
      "value": ThemeMode.light,
      "customTheme": 'default',
      "subtitle": "Tema claro predeterminado",
      "icon": CupertinoIcons.sun_max
    },
    {
      "title": 'Tema Oscuro',
      "value": ThemeMode.dark,
      "customTheme": 'default',
      "subtitle": "Tema oscuro predeterminado",
      "icon": CupertinoIcons.moon_fill
    },
    {
      "title": 'Tema Cuaderno',
      "value": ThemeMode.light,
      "customTheme": 'notebook',
      "subtitle": "Estilo de cuaderno con líneas",
      "icon": Icons.book
    },
    {
      "title": 'Tema Noche Azulada',
      "value": ThemeMode.dark,
      "customTheme": 'bluenight',
      "subtitle": "Tema oscuro con tonos azules",
      "icon": Icons.nights_stay
    }
  ];

  @override
  Widget build(BuildContext context) {
    final themeModeNotifier = Provider.of<ThemeModeNotifier>(context);
    _selectedThemeMode = themeModeNotifier.getThemeMode();
    _selectedCustomTheme = themeModeNotifier.getCustomTheme();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Selecciona un tema',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
              ),
            ),
            ..._options.map((option) {
              final isSelected = _selectedThemeMode == option['value'] &&
                  _selectedCustomTheme == option['customTheme'];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                elevation: isSelected ? 2 : 0,
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: RadioListTile(
                  value: {
                    'mode': option['value'],
                    'theme': option['customTheme']
                  },
                  groupValue: {
                    'mode': _selectedThemeMode,
                    'theme': _selectedCustomTheme
                  },
                  title: Row(
                    children: [
                      Icon(option['icon']),
                      const SizedBox(width: 16),
                      Text(
                        option['title'],
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Text(option['subtitle']),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      _setSelectedThemeMode(value['mode'] as ThemeMode,
                          value['theme'] as String, themeModeNotifier);
                    }
                  },
                  selected: isSelected,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _setSelectedThemeMode(ThemeMode mode, String customTheme,
      ThemeModeNotifier themeModeNotifier) async {
    themeModeNotifier.setThemeMode(mode, customTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', mode.index);
    prefs.setString('customTheme', customTheme);
    setState(() {
      _selectedThemeMode = mode;
      _selectedCustomTheme = customTheme;
    });
  }
}

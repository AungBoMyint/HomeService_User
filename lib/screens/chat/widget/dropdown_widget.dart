import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/translations_language_code.dart';

class DropDownWidget extends StatelessWidget {
  final String value;
  final void Function(String?)? onChangedLanguage;

  const DropDownWidget({
    required this.value,
    required this.onChangedLanguage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = Translations.languages
        .map<DropdownMenuItem<String>>(
            (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
        .toList();

    return DropdownButton<String>(
      value: value,
      icon: Icon(Icons.expand_more, color: Colors.white),
      iconSize: 24,
      elevation: 16,
      dropdownColor: context.primaryColor,
      style: TextStyle(color: Colors.white),
      onChanged: onChangedLanguage,
      items: items,
    );
  }
}

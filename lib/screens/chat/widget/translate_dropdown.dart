import 'package:flutter/material.dart';
import 'dropdown_widget.dart';

class TitleWidget extends StatelessWidget {
  final String language1;
  final String language2;
  final void Function(String?)? onChangedLanguage1;
  final void Function(String?)? onChangedLanguage2;

  const TitleWidget({
    required this.language1,
    required this.language2,
    required this.onChangedLanguage1,
    required this.onChangedLanguage2,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropDownWidget(
            value: language1,
            onChangedLanguage: onChangedLanguage1,
          ),
          SizedBox(width: 12),
          /* Icon(Icons.translate, color: Colors.white),
          SizedBox(width: 12), */
          DropDownWidget(
            value: language2,
            onChangedLanguage: onChangedLanguage2,
          ),
        ],
      );
}

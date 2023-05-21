import 'dart:convert';
import 'dart:developer';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;

class TranslationApi {
  static final _apiKey = 'AIzaSyC5GTOxzUYQlWslE9tghaLC0Wdj9LBcaKE';

  static Future<String> translate(String message, String toLanguageCode) async {
    final url = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?target=$toLanguageCode&key=$_apiKey&q=$message');
    Response? response;
    try {
      response = await http.post(
        url,
      );
    } catch (e) {
      log("Error: $e");
    }

    if (!(response == null) && response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final translations = body['data']['translations'] as List;
      final translation = translations.first;

      return HtmlUnescape().convert(translation['translatedText']);
    } else {
      throw Exception();
    }
  }

  static Future<String> translate2(
      String message, String fromLanguageCode, String toLanguageCode) async {
    final translation = await GoogleTranslator().translate(
      message,
      from: fromLanguageCode,
      to: toLanguageCode,
    );

    return translation.text;
  }
}

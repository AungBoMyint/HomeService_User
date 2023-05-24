class Translations {
  static final languages = <String>[
    'English',
    'Thai',
    'Burmese',
  ];

  static String getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en';
      case 'Thai':
        return 'th';
      case 'Burmese':
        return 'my';
      default:
        return 'en';
    }
  }
}

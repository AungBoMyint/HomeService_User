class Translations {
  static final languages = <String>[
    'English',
    'Thai',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Russian'
  ];

  static String getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en';
      case 'Thai':
        return 'th';
      case 'French':
        return 'fr';
      case 'Italian':
        return 'it';
      case 'Russian':
        return 'ru';
      case 'Spanish':
        return 'es';
      case 'German':
        return 'de';
      default:
        return 'en';
    }
  }
}

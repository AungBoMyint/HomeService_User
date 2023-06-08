import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

const APP_NAME = 'Home Service for Thailand';
const APP_NAME_TAG_LINE = 'Everything you will need for your Home';
const DEFAULT_LANGUAGE = 'en';

const DOMAIN_URL = 'https://homeserviceforthai.com';
const BASE_URL = '$DOMAIN_URL/api/';

/// You can change this to your Provider App package name
/// This will be used in Registered As Partner in Sign In Screen where your users can redirect to the Play/App Store for Provider App
/// You can specify in Admin Panel, These will be used if you don't specify in Admin Panel
const PROVIDER_PACKAGE_NAME = 'com.iqonic.provider';
const IOS_LINK_FOR_PARTNER =
    "https://apps.apple.com/in/app/handyman-provider-app/id1596025324";

const IOS_LINK_FOR_USER =
    'https://apps.apple.com/us/app/handyman-service-user/id1591427211';

var defaultPrimaryColor = Color(0xFF5F60B9);
const DASHBOARD_AUTO_SLIDER_SECOND = 5;

const TERMS_CONDITION_URL = 'https://iqonic.design/terms-of-use/';
const PRIVACY_POLICY_URL = 'https://iqonic.design/privacy-policy/';
const HELP_SUPPORT_URL = 'https://iqonic.desky.support/';
const PURCHASE_URL =
    'https://codecanyon.net/item/handyman-service-flutter-ondemand-home-services-app-with-complete-solution/33776097?s_rank=16';

const STRIPE_MERCHANT_COUNTRY_CODE = 'TH';
const STRIPE_CURRENCY_CODE = 'TH';
DateTime todayDate = DateTime(2022, 8, 24);

/// SADAD PAYMENT DETAIL
const SADAD_API_URL = 'https://api-s.sadad.qa';
const SADAD_PAY_URL = "https://d.sadad.qa";

Country defaultCountry() {
  return Country(
    phoneCode: '66',
    countryCode: 'TH',
    e164Sc: 66,
    geographic: true,
    level: 1,
    name: 'Thailand',
    example: '834051877',
    displayName: 'Thailand (TH) [+66]',
    displayNameNoCountryCode: 'Thailand (TH)',
    e164Key: '66-TH-0',
    fullExampleWithPlusSign: '+66834051877',
  );
}

/// You can now update OneSignal Keys from Admin Panel in Setting.
/// These keys will be used if you haven't added in Admin Panel.
/* const ONESIGNAL_APP_ID = 'db58e3ae-3940-47b2-b77c-23b78c734e3f';
const ONESIGNAL_REST_KEY = "NzA0ZjA3MmEtZTY3Yy00NTA2LTg0OWEtNmRhNTQwMmEyYzM2";
const ONESIGNAL_CHANNEL_ID = "56e9a0f8-ab51-40d1-a520-5d3a72035560";
 */
const ONESIGNAL_APP_ID = '349daeb0-f597-44f6-bc01-45001cf0642a';
const ONESIGNAL_REST_KEY = "NDU2NGZlZTgtZGU0Ni00MzUwLWFmMGYtMWMxOTJhYzkwNDQy";
const ONESIGNAL_CHANNEL_ID = "4d8ac17b-9045-40a0-8223-705ae76cbf10";

const LOCAL_NOTIFICATION_KEY = "local_notification_key";

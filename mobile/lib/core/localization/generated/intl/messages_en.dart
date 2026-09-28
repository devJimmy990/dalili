// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error) => "Couldn\'t start the camera: ${error}";

  static String m1(value) => "Heading: ${value}°";

  static String m2(distance) => "Continue straight for ${distance} m";

  static String m3(distance) => "Start walking for ${distance} m";

  static String m4(distance) => "${distance} m remaining";

  static String m5(value) => "Target difference: ${value}°";

  static String m6(code) => "Unrecognized QR code: ${code}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addedToFavorites": MessageLookupByLibrary.simpleMessage(
      "Added to favorites",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Dalili"),
    "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "author": MessageLookupByLibrary.simpleMessage("Author"),
    "bookLanguage": MessageLookupByLibrary.simpleMessage("Language"),
    "bookNotFound": MessageLookupByLibrary.simpleMessage("Book not found"),
    "bookNotFoundDesc": MessageLookupByLibrary.simpleMessage(
      "This book was not found in the database",
    ),
    "bookRecognized": MessageLookupByLibrary.simpleMessage("Book recognized!"),
    "callNumber": MessageLookupByLibrary.simpleMessage("Call Number"),
    "classification": MessageLookupByLibrary.simpleMessage("Classification"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
    "continueBtn": MessageLookupByLibrary.simpleMessage("Continue"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Dark"),
    "department": MessageLookupByLibrary.simpleMessage("Department"),
    "departments": MessageLookupByLibrary.simpleMessage("Departments"),
    "edition": MessageLookupByLibrary.simpleMessage("Edition"),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "error": MessageLookupByLibrary.simpleMessage("An error occurred"),
    "favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
    "getStarted": MessageLookupByLibrary.simpleMessage("Get Started"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "indoorNav": MessageLookupByLibrary.simpleMessage("Indoor Navigation"),
    "isbn": MessageLookupByLibrary.simpleMessage("ISBN"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "lightTheme": MessageLookupByLibrary.simpleMessage("Light"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "navArNavigationTitle": MessageLookupByLibrary.simpleMessage(
      "AR Navigation",
    ),
    "navArrivedMessage": MessageLookupByLibrary.simpleMessage(
      "You\'ve arrived at your destination 🎉",
    ),
    "navCameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Camera permission is required for AR navigation. Please grant it in system settings.",
    ),
    "navCameraStartError": m0,
    "navCancelNavigationBody": MessageLookupByLibrary.simpleMessage(
      "Leaving now will cancel your current trip. You\'ll need to select a destination and scan a QR code again to restart.",
    ),
    "navCancelNavigationTitle": MessageLookupByLibrary.simpleMessage(
      "Cancel navigation?",
    ),
    "navCancelTrip": MessageLookupByLibrary.simpleMessage("Cancel trip"),
    "navDone": MessageLookupByLibrary.simpleMessage("Done"),
    "navGoStraight": MessageLookupByLibrary.simpleMessage("Go straight"),
    "navHeadingLabel": m1,
    "navInstructionForward": m2,
    "navInstructionStart": m3,
    "navKeepGoing": MessageLookupByLibrary.simpleMessage("Keep going"),
    "navNoCameraFound": MessageLookupByLibrary.simpleMessage(
      "No camera was found on this device.",
    ),
    "navNoDestinationsFound": MessageLookupByLibrary.simpleMessage(
      "No destinations found in this map.",
    ),
    "navRemainingDistance": m4,
    "navRetryLabel": MessageLookupByLibrary.simpleMessage("Retry"),
    "navScanCurrentQrTitle": MessageLookupByLibrary.simpleMessage(
      "Scan Current QR",
    ),
    "navScanQrAgain": MessageLookupByLibrary.simpleMessage("Scan QR Again"),
    "navScanQrTooltip": MessageLookupByLibrary.simpleMessage("Scan QR again"),
    "navScanStartQrTitle": MessageLookupByLibrary.simpleMessage(
      "Scan Start QR",
    ),
    "navSelectDestinationHint": MessageLookupByLibrary.simpleMessage(
      "Select where you want to go",
    ),
    "navSensorPermissionError": MessageLookupByLibrary.simpleMessage(
      "Motion & fitness / location permission is required for live navigation. Please grant it in system settings and try again.",
    ),
    "navSlightLeft": MessageLookupByLibrary.simpleMessage("Bear left slightly"),
    "navSlightRight": MessageLookupByLibrary.simpleMessage(
      "Bear right slightly",
    ),
    "navTargetDifferenceLabel": m5,
    "navTurnLeft": MessageLookupByLibrary.simpleMessage("Turn left"),
    "navTurnRight": MessageLookupByLibrary.simpleMessage("Turn right"),
    "navUTurn": MessageLookupByLibrary.simpleMessage("Turn around"),
    "navUnrecognizedQr": m6,
    "navigation": MessageLookupByLibrary.simpleMessage("Navigation"),
    "noArticles": MessageLookupByLibrary.simpleMessage("No articles available"),
    "noFavorites": MessageLookupByLibrary.simpleMessage("No favorites yet"),
    "noResults": MessageLookupByLibrary.simpleMessage("No results found"),
    "onboardNavDesc": MessageLookupByLibrary.simpleMessage(
      "Get guided directions to any book\'s exact shelf location inside the library.",
    ),
    "onboardNavTitle": MessageLookupByLibrary.simpleMessage("Navigate Indoors"),
    "onboardScanDesc": MessageLookupByLibrary.simpleMessage(
      "Point your camera at a book\'s barcode to instantly find it in our library catalog.",
    ),
    "onboardScanTitle": MessageLookupByLibrary.simpleMessage("Scan Any Book"),
    "pointCameraAtBook": MessageLookupByLibrary.simpleMessage(
      "Point camera at a book barcode",
    ),
    "publisher": MessageLookupByLibrary.simpleMessage("Publisher"),
    "relatedArticles": MessageLookupByLibrary.simpleMessage("Related Articles"),
    "removedFromFavorites": MessageLookupByLibrary.simpleMessage(
      "Removed from favorites",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "scanAgain": MessageLookupByLibrary.simpleMessage("Scan Again"),
    "scanBook": MessageLookupByLibrary.simpleMessage("Scan Book"),
    "scanHintBottom": MessageLookupByLibrary.simpleMessage(
      "Hold steady for best results",
    ),
    "scanInstruction": MessageLookupByLibrary.simpleMessage(
      "Align the barcode within the frame",
    ),
    "searchBooks": MessageLookupByLibrary.simpleMessage("Search Books"),
    "searchHint": MessageLookupByLibrary.simpleMessage(
      "Search books, articles...",
    ),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Select Language"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "shelf": MessageLookupByLibrary.simpleMessage("Shelf"),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "suggestedBooks": MessageLookupByLibrary.simpleMessage("Suggested Books"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "viewAll": MessageLookupByLibrary.simpleMessage("View All"),
    "viewDetails": MessageLookupByLibrary.simpleMessage("View Details"),
    "welcomeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Your smart library assistant",
    ),
    "welcomeTitle": MessageLookupByLibrary.simpleMessage("Welcome to Dalili"),
    "year": MessageLookupByLibrary.simpleMessage("Year"),
  };
}

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
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
  String get localeName => 'ar';

  static String m0(error) => "تعذر تشغيل الكاميرا: ${error}";

  static String m1(value) => "الاتجاه: ${value}°";

  static String m2(distance) => "استمر مستقيمًا ${distance} متر";

  static String m3(distance) => "ابدأ السير لمسافة ${distance} متر";

  static String m4(distance) => "متبقي ${distance} م";

  static String m5(value) => "فرق الاتجاه: ${value}°";

  static String m6(code) => "كود QR غير معروف: ${code}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addedToFavorites": MessageLookupByLibrary.simpleMessage(
      "تمت الإضافة إلى المفضلة",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("دليلي"),
    "arabic": MessageLookupByLibrary.simpleMessage("العربية"),
    "author": MessageLookupByLibrary.simpleMessage("المؤلف"),
    "bookLanguage": MessageLookupByLibrary.simpleMessage("اللغة"),
    "bookNotFound": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على الكتاب",
    ),
    "bookNotFoundDesc": MessageLookupByLibrary.simpleMessage(
      "لم يُعثر على هذا الكتاب في قاعدة البيانات",
    ),
    "bookRecognized": MessageLookupByLibrary.simpleMessage(
      "تم التعرف على الكتاب!",
    ),
    "callNumber": MessageLookupByLibrary.simpleMessage("رقم التصنيف"),
    "classification": MessageLookupByLibrary.simpleMessage("التصنيف"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("قريباً"),
    "continueBtn": MessageLookupByLibrary.simpleMessage("متابعة"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("داكن"),
    "department": MessageLookupByLibrary.simpleMessage("القسم"),
    "departments": MessageLookupByLibrary.simpleMessage("الأقسام"),
    "edition": MessageLookupByLibrary.simpleMessage("الطبعة"),
    "english": MessageLookupByLibrary.simpleMessage("الإنجليزية"),
    "error": MessageLookupByLibrary.simpleMessage("حدث خطأ ما"),
    "favorites": MessageLookupByLibrary.simpleMessage("المفضلة"),
    "getStarted": MessageLookupByLibrary.simpleMessage("ابدأ الآن"),
    "home": MessageLookupByLibrary.simpleMessage("الرئيسية"),
    "indoorNav": MessageLookupByLibrary.simpleMessage("التنقل الداخلي"),
    "isbn": MessageLookupByLibrary.simpleMessage("الرقم الدولي"),
    "language": MessageLookupByLibrary.simpleMessage("اللغة"),
    "lightTheme": MessageLookupByLibrary.simpleMessage("فاتح"),
    "loading": MessageLookupByLibrary.simpleMessage("جاري التحميل..."),
    "navArNavigationTitle": MessageLookupByLibrary.simpleMessage(
      "الملاحة بالواقع المعزز",
    ),
    "navArrivedMessage": MessageLookupByLibrary.simpleMessage(
      "لقد وصلت إلى وجهتك 🎉",
    ),
    "navCameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "لازم صلاحية الكاميرا عشان تشتغل الملاحة بالواقع المعزز. من فضلك فعّلها من إعدادات النظام.",
    ),
    "navCameraStartError": m0,
    "navCancelNavigationBody": MessageLookupByLibrary.simpleMessage(
      "الخروج دلوقتي هيلغي رحلتك الحالية. هتحتاج تختار وجهة وتمسح QR تاني عشان تبدأ من جديد.",
    ),
    "navCancelNavigationTitle": MessageLookupByLibrary.simpleMessage(
      "إلغاء التنقل؟",
    ),
    "navCancelTrip": MessageLookupByLibrary.simpleMessage("ألغِ الرحلة"),
    "navDone": MessageLookupByLibrary.simpleMessage("تم"),
    "navGoStraight": MessageLookupByLibrary.simpleMessage("استمر للأمام"),
    "navHeadingLabel": m1,
    "navInstructionForward": m2,
    "navInstructionStart": m3,
    "navKeepGoing": MessageLookupByLibrary.simpleMessage("أكمل"),
    "navNoCameraFound": MessageLookupByLibrary.simpleMessage(
      "مفيش كاميرا متاحة على الجهاز ده.",
    ),
    "navNoDestinationsFound": MessageLookupByLibrary.simpleMessage(
      "مفيش وجهات في الخريطة دي.",
    ),
    "navRemainingDistance": m4,
    "navRetryLabel": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "navScanCurrentQrTitle": MessageLookupByLibrary.simpleMessage(
      "امسح QR موقعك الحالي",
    ),
    "navScanQrAgain": MessageLookupByLibrary.simpleMessage("امسح QR تاني"),
    "navScanQrTooltip": MessageLookupByLibrary.simpleMessage("امسح QR تاني"),
    "navScanStartQrTitle": MessageLookupByLibrary.simpleMessage(
      "امسح QR نقطة البداية",
    ),
    "navSelectDestinationHint": MessageLookupByLibrary.simpleMessage(
      "اختر وجهتك",
    ),
    "navSensorPermissionError": MessageLookupByLibrary.simpleMessage(
      "لازم صلاحية الحركة والموقع عشان تشتغل الملاحة المباشرة. من فضلك فعّلها من إعدادات النظام وحاول تاني.",
    ),
    "navSlightLeft": MessageLookupByLibrary.simpleMessage(
      "انحرف قليلاً يساراً",
    ),
    "navSlightRight": MessageLookupByLibrary.simpleMessage(
      "انحرف قليلاً يميناً",
    ),
    "navTargetDifferenceLabel": m5,
    "navTurnLeft": MessageLookupByLibrary.simpleMessage("لف يسار"),
    "navTurnRight": MessageLookupByLibrary.simpleMessage("لف يمين"),
    "navUTurn": MessageLookupByLibrary.simpleMessage("استدر للخلف"),
    "navUnrecognizedQr": m6,
    "navigation": MessageLookupByLibrary.simpleMessage("التنقل"),
    "noArticles": MessageLookupByLibrary.simpleMessage("لا توجد مقالات"),
    "noFavorites": MessageLookupByLibrary.simpleMessage("لا توجد مفضلات بعد"),
    "noResults": MessageLookupByLibrary.simpleMessage("لا توجد نتائج"),
    "onboardNavDesc": MessageLookupByLibrary.simpleMessage(
      "احصل على إرشادات للوصول إلى الرف الدقيق لأي كتاب داخل المكتبة.",
    ),
    "onboardNavTitle": MessageLookupByLibrary.simpleMessage("التنقل الداخلي"),
    "onboardScanDesc": MessageLookupByLibrary.simpleMessage(
      "وجّه الكاميرا نحو الباركود الخاص بأي كتاب للعثور عليه فوراً في فهرس المكتبة.",
    ),
    "onboardScanTitle": MessageLookupByLibrary.simpleMessage("امسح أي كتاب"),
    "pointCameraAtBook": MessageLookupByLibrary.simpleMessage(
      "وجّه الكاميرا نحو باركود الكتاب",
    ),
    "publisher": MessageLookupByLibrary.simpleMessage("الناشر"),
    "relatedArticles": MessageLookupByLibrary.simpleMessage("مقالات ذات صلة"),
    "removedFromFavorites": MessageLookupByLibrary.simpleMessage(
      "تمت الإزالة من المفضلة",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "scanAgain": MessageLookupByLibrary.simpleMessage("مسح مجدداً"),
    "scanBook": MessageLookupByLibrary.simpleMessage("مسح الكتاب"),
    "scanHintBottom": MessageLookupByLibrary.simpleMessage(
      "حافظ على الثبات للحصول على أفضل النتائج",
    ),
    "scanInstruction": MessageLookupByLibrary.simpleMessage(
      "ضع الباركود داخل الإطار",
    ),
    "searchBooks": MessageLookupByLibrary.simpleMessage("البحث في الكتب"),
    "searchHint": MessageLookupByLibrary.simpleMessage(
      "ابحث عن كتب أو مقالات...",
    ),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("اختر اللغة"),
    "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "shelf": MessageLookupByLibrary.simpleMessage("الرف"),
    "skip": MessageLookupByLibrary.simpleMessage("تخطي"),
    "suggestedBooks": MessageLookupByLibrary.simpleMessage("كتب مقترحة"),
    "theme": MessageLookupByLibrary.simpleMessage("المظهر"),
    "viewAll": MessageLookupByLibrary.simpleMessage("عرض الكل"),
    "viewDetails": MessageLookupByLibrary.simpleMessage("عرض التفاصيل"),
    "welcomeSubtitle": MessageLookupByLibrary.simpleMessage(
      "مساعدك الذكي في المكتبة",
    ),
    "welcomeTitle": MessageLookupByLibrary.simpleMessage("مرحباً بك في دليلي"),
    "year": MessageLookupByLibrary.simpleMessage("السنة"),
  };
}

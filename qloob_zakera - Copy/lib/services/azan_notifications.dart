import 'dart:convert';
import 'dart:developer';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:azkark/services/models.dart';
import 'package:azkark/services/time_util.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/print_log.dart';
import '../util/support_app.dart';
import 'azan_notifications_old.dart';
// import 'azan_notificationss.dart';
import 'notification_services.dart';
import 'package:timezone/data/latest.dart' as tz;

var prayerrs = [
  Prayerr("00:00", "الفجر", false),
  Prayerr("00:00", "الشروق", false),
  Prayerr("00:00", "الظهر", false),
  Prayerr("00:00", "العصر", false),
  Prayerr("00:00", "المغرب", false),
  Prayerr("00:00", "لعشاء", false),
];
List<DateTime> listAzanTime = [];
SharedPreferences myPref;
List<Prayerr> todayPrayerrTime = [];
const String keyAzanDateUpdate = 'DateUpdate';
const String keyAzanSound = 'AzanSound';
Prayerr getNextPrayer() {
  DateTime now = DateTime.now();

  Prayerr myPrayer = prayerrs[0];
  var index = 0;
  for (var element in prayerrs) {
    index++;
    element.selected = false;
    if (intFromTime(DateFormat("HH:mm").parse(element.time)) >
        intFromTime(now)) {
      //Upcoming prayer
      myPrayer = element;
      break;
    } else if (intFromTime(DateFormat("HH:mm").parse(element.time)) ==
        intFromTime(now)) {
      //Current prayer
      myPrayer = element;
      myPrayer.status = "now";
      break;
    } else {
      //Last prayer
      myPrayer = element;
      myPrayer.status = "final";
      prayerrs[index - 1].selected = false;
    }
  }
  if (index != 1) {
    prayerrs[index - 2].selected = true;
  }
  return myPrayer;
}

String calculateRemindTime(Prayerr prayer) {
  //now, upcoming, final
  DateTime now = DateTime.now();
  if (prayer.status == "now") {
    return "حان الآن وعد صلاة";
  } else if (prayer.status == "upcoming") {
    var remindTime =
        intFromTime(DateFormat("HH:mm").parse(prayer.time)) - intFromTime(now);
    return " تبقى ${durationToString(remindTime)} لصلاة ";
  } else {
    return "تقبل الله طاعتكم";
  }
}

Future<Map<String, dynamic>> getCountry() async {
  return jsonDecode((await http.get(Uri.parse("http://ip-api.com/json"))).body);
}

bool isSameDate(DateTime date1, DateTime date2) {
  if (date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day) {
    return true;
  }

  return false;
}

/// Get all Prayerrs in this month
Future<List<PrayerrDate>> getAllData() async {
  var dateNow = DateTime.now();
  List<PrayerrDate> allPrayerrsForMonth = [];
  var prefs = await SharedPreferences.getInstance();

  final uri = Uri.parse('https://api.aladhan.com/v1/calendarByCity')
      .replace(queryParameters: {
    'city': prefs.get('city') ?? "Damascus",
    'country': prefs.get('country') ?? "Syria",
    'month': dateNow.month.toString(),
    'year': dateNow.year.toString(),
  });

  final response = await http.get(uri);
  await prefs.setString("prayers_month", dateNow.month.toString());
  allPrayerrsForMonth.addAll(fromJson(jsonDecode(response.body)));

  return allPrayerrsForMonth;
}

List<PrayerrDate> fromJson(Map<String, dynamic> json) {
  var Prayerrs = json["data"] as List<dynamic>;
  return Prayerrs.map((e) => PrayerrDate.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// Get all Prayerr in this day from cache or from internet.
Future<List<Prayerr>> updatePrayerrs(Function() changeLocation) async {
  var prefs = await SharedPreferences.getInstance();
  myPref = await SharedPreferences.getInstance();
  String PrayerrJs;

  Map<String, dynamic> location = {'n': "s"};
  if (prefs.get('city') != null && prefs.get('country') != null) {
    location['city'] = prefs.get('city');
    location['country'] = prefs.get('country');
  } else {
    try {
      location = await getCountry();
      prefs.setString('country', location['country']);
      prefs.setString('city', 'cairo');
      log("Get new location ${location['country']}");
      log("Get new location ${location['city']}");
    } catch (e) {
      throw Exception("time out");
    }
  }

  if (location['country'] != prefs.getString('country')) {
    prefs.setString('prayers', "");
    prefs.setString('country', location['country']);
    prefs.setString('city', location['city']);
  } else {
    PrayerrJs = prefs.getString('prayers');
    // log(PrayerrJs.toString());
  }

  var dateNow = DateTime.now();
  if (prefs.getString("prayers_month") != dateNow.month.toString()) {
    PrayerrJs = null;
  }

  List<Prayerr> todayPrayerr = [];
  log('PrayerrJs');
  // log(PrayerrJs);
  log('PrayerrJssssssssss');
  if (PrayerrJs != null) {
    DateTime now = DateTime.now();
    for (var element in (jsonDecode(PrayerrJs) as List<dynamic>)) {
      // log(DateFormat("dd-MM-yyyy").parse(element["date"]).toString());
      // log(now.toString());

      if (isSameDate(DateFormat("dd-MM-yyyy").parse(element["date"]), now)) {
        // log('"prayers"');
        // log(element["prayers"]);
        todayPrayerr = (jsonDecode(element["prayers"]) as List<dynamic>)
            .map((e) => Prayerr.fromJson(e))
            .toList();
      }
      // log('"Get data Not for first time"');
      // log(todayPrayerr[0].time);
      // log(todayPrayerr[6].time);
    }
  } else {
    print("Get data for the first time ");
    var allDates = await getAllData();
    DateTime now = DateTime.now();
    prefs.setString('prayers',
        jsonEncode(allDates, toEncodable: (e) => (e as PrayerrDate).toJson()));

    for (var element in allDates) {
      log(DateFormat("dd-MM-yyyy").parse(element.date).toString());
      log(now.toString());
      if (isSameDate(DateFormat("dd-MM-yyyy").parse(element.date), now)) {
        //Get the Prayerrs of this day.
        todayPrayerr = element.prayerrs;
        log('"Get data Not for first time"');
      } else {
        log("Prayerrs of ${DateFormat("dd-MM-yyyy").parse(element.date)} are not exists");
      }
    }
  }
  getCountry().then((value) async {
    if (value['country'] != prefs.get('country')) {
      print("Get data for the first time CHANGE COUNTRY");

      await prefs.setString('country', value['country']);
      await prefs.setString('city', value['city']);

      var allDates = await getAllData();

      await prefs.setString(
          'prayers',
          jsonEncode(allDates,
              toEncodable: (e) => (e as PrayerrDate).toJson()));

      changeLocation();
    }
  });

  // listAzanTime.forEach((element) {
  //   log(element.toString());
  // });
  // myPref.setString(keyAzanDateUpdate, myCustomDateTimeYYYYMMDD());

  todayPrayerrTime = todayPrayerr;
  return todayPrayerr;
}

Future<bool> getAzanNextDay() async {
  // print(todayPrayerrTime);
  // todayPrayerrTime.forEach((element) {
  //   final endIndex = element.time.indexOf(" (EET)", 0);
  //   log(element.time.substring(0, 5));
  // });

  if (todayPrayerrTime.isNotEmpty) {
    listAzanTime.clear();
    List<String> time = [];
    todayPrayerrTime.forEach((element) {
      time.add(element.time.substring(0, 5));
    });

    // log('time');
    // log(time[0]);
    log(DateTime.parse(myCustomDateTimeYYYYMMDD() + " " + time[0]).toString());
    listAzanTime = [
      /// Fajr index 0
      // DateTime.parse("2022-08-25 11:44"),
      DateTime.parse(myCustomDateTimeYYYYMMDD() + " " + time[0]),

      /// Dhuhr index 1
      DateTime.parse(myCustomDateTimeYYYYMMDD() + " " + time[2]),

      /// Asr index 2
      DateTime.parse(myCustomDateTimeYYYYMMDD() + " " + time[3]),

      /// maghrib index 3
      DateTime.parse(myCustomDateTimeYYYYMMDD() + " " + time[5]),

      /// Isha index 4
      DateTime.parse(myCustomDateTimeYYYYMMDD() + " " + time[6]),
    ];

    myPref.setString(keyAzanDateUpdate, myCustomDateTimeYYYYMMDD());
    return true;
  } else {
    printLog(stateID: "513469", data: 'error', isSuccess: false);
    myPref.setString(keyAzanDateUpdate, "is Not Updated");
    return false;
  }
}

/// Step 1 of 3
startAzanNotificationn() async {
  // await AndroidAlarmManager.initialize();


  myPref = await SharedPreferences.getInstance();
  if (await getAzanNextDay() == true) {
    // listAzanTime.forEach((element) {
    //   log(element.toString());
    // });
    if (listAzanTime[0].isAfter(DateTime.now())) {

      await AndroidAlarmManager.oneShotAt(
        listAzanTime[0],
        0,
        startNotification,
        wakeup: true,
        allowWhileIdle: true,
        exact: true,
        rescheduleOnReboot: true,
      );
    }

    if (listAzanTime[1].isAfter(DateTime.now())) {
      await AndroidAlarmManager.oneShotAt(
        listAzanTime[1],
        1,
        startNotification,
        wakeup: true,
        allowWhileIdle: true,
        exact: true,
        rescheduleOnReboot: true,
      );
    }

    if (listAzanTime[2].isAfter(DateTime.now())) {
      await AndroidAlarmManager.oneShotAt(
        listAzanTime[2],
        2,
        startNotification,
        wakeup: true,
        allowWhileIdle: true,
        exact: true,
        rescheduleOnReboot: true,
      );
    }

    if (listAzanTime[3].isAfter(DateTime.now())) {
      await AndroidAlarmManager.oneShotAt(
        // DateTime.now(),
        listAzanTime[3],
        3,
        startNotification,
        wakeup: true,
        allowWhileIdle: true,
        exact: true,
        rescheduleOnReboot: true,
      );
    }

    if (listAzanTime[4].isAfter(DateTime.now())) {
      await AndroidAlarmManager.oneShotAt(
        listAzanTime[4],
        4,
        startNotification,
        wakeup: true,
        allowWhileIdle: true,
        exact: true,
        rescheduleOnReboot: true,
      );
    }
  }

  String fullDate = myCustomDateTimeYYYYMMDD() + " 00:10";
  await AndroidAlarmManager.oneShotAt(
      DateTime.parse(fullDate).add(const Duration(days: 1)), 5, getAzanNextDay,
      wakeup: true,
      allowWhileIdle: true,
      exact: true,
      rescheduleOnReboot: true);

  // } else {
  //   printLog(
  //       stateID: "423196",
  //       data: "Error Internet not connected",
  //       isSuccess: false);

  //   /// write code here internet not connected
  //   ///TODO AhmadCode
  // }
}

/// Step 2 of 3
void startNotification() async {
  // final int isolateId = Isolate.current.hashCode;
  await initTimeZonesAndNotification();
  printLog(stateID: "442902", data: "startNotification", isSuccess: true);
  NotificationServices().showNotification(
      id: 1,
      title: "وقت الصلاة الآن",
      body: "ما رأيت شيئاً من العبادة أشد من الصلاة في جوف الليل",
      seconds: 3,
      sound: await getAzanSound());
}

/// Step 3 of 3
initTimeZonesAndNotification() async {
  tz.initializeTimeZones();
  await NotificationServices().initNotification();
}

setAzanSound(String azanName) async {
  try {
    myPref = await SharedPreferences.getInstance();
    await myPref.setString(keyAzanSound, azanName);

    printLog(stateID: "502109", data: "Saved Azan Sound", isSuccess: true);
  } catch (error) {
    printLog(stateID: "088183", data: error.toString(), isSuccess: false);
  }
}

Future<String> getAzanSound() async {
  try {
    myPref = await SharedPreferences.getInstance();
    String azanName = myPref.getString(keyAzanSound);

    if (azanName == null) {
      printLog(
          stateID: "355309",
          data: "Done Get Azan Sound by Default",
          isSuccess: true);
      return "a";
    } else {
      printLog(
          stateID: "539232",
          data: "Done Get Azan Sound by Saved",
          isSuccess: true);
      return azanName;
    }
  } catch (error) {
    printLog(
        stateID: "088371",
        data: "Error getAzansound${error.toString()}",
        isSuccess: false);
    return "a";
  }
}

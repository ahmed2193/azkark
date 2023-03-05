import 'dart:convert';

class Prayerr {
  String time;
  String title;
  bool selected = false;
  String status = "upcoming"; // now, upcoming, final

  Prayerr(this.time, this.title, this.selected);

  Map<String, dynamic> toJson() => {
        'time': time,
        'title': title,
        'selected': selected,
        'status': status,
      };

  factory Prayerr.fromJson(Map<String, dynamic> value) {
    return Prayerr(value["time"],value["title"],value["selected"]);
  }

}

class PrayerrDate {
  PrayerrDate(this.date, this.prayerrs);

  List<Prayerr> prayerrs;
  String date;

  factory PrayerrDate.fromJson(Map<String, dynamic> json) {
    List<Prayerr> prayerrs = [];
    (json["timings"] as Map<String, dynamic>).forEach((key, value) {
      prayerrs.add(Prayerr(value, key, false));
    });
    var dateGregorianModel = (json["date"] as Map<String, dynamic>)["gregorian"] as Map<String, dynamic>;
    return PrayerrDate(dateGregorianModel["date"], prayerrs);
  }

  factory PrayerrDate.fromJsonPrf(Map<String, dynamic> value) {
    List<Prayerr> prayerrs = [];
    prayerrs.add(Prayerr(value["time"], value["title"], value["selected"]));
    return PrayerrDate(value["date"], prayerrs);
  }

  Map<String, dynamic> toJson() => {
        'prayers': jsonEncode(prayerrs, toEncodable: (e) => (e as Prayerr).toJson()),
        'date': date,
      };
}

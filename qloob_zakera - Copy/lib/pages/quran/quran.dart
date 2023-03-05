import 'dart:convert';
import 'dart:math';
import 'package:azkark/database/cache_heper.dart';
import 'package:azkark/pages/quran/Sora.dart';
import 'package:azkark/pages/quran/presination/screens/surah_builder.dart';
import 'package:azkark/pages/quran/presination/widgets/arabic_sura_num.dart';
import 'package:azkark/providers/setting_cubit.dart';
import 'package:azkark/providers/settings_provider.dart';
import 'package:azkark/util/assets_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../models/surah.dart';
import '../../util/colors.dart';
import '../../util/components.dart';
import '../../util/conestans.dart';

class Quran extends StatefulWidget {
  const Quran({Key key}) : super(key: key);

  @override
  _QuranState createState() => _QuranState();
}

class _QuranState extends State<Quran> with TickerProviderStateMixin {
  List<Surah> surahList = [];
  int selectedIndex = 0;
  bool isReverse = false;
  double fontSize;

  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    fontSize = Provider.of<SettingsProvider>(context, listen: false)
        .getsettingField('font_size');

    readJson();
    super.initState();
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/surah.json');
    final data = await json.decode(response);
    for (var item in data["chapters"]) {
      surahList.add(Surah.fromMap(item));
    }
    debugPrint(surahList.length.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingCubit, SettingStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = SettingCubit.get(context);
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Switch(
                onChanged: (value) async {
                  debugPrint('Switch ${cubit.isMoshaf}');
                  setState(() {
                    cubit.isMoshaf = value;
                  });
                  ShowToust(
                      Text: cubit.isMoshaf ? 'وضع مشاف' : 'الوضع العادي',
                      state: ToustStates.SUCSESS);
                  // int valueInt= switchValue ? 1: 0;
                  // await settingsProvider.updateSettings(widget.nameField,valueInt);
                },
                value: cubit.isMoshaf,
                activeColor: blue[700],
                activeTrackColor: blue[500],
                inactiveThumbColor: blue[200],
                inactiveTrackColor: blue[300],
              ),
              actions: [
                Transform.rotate(
                  angle: isReverse ? pi : 2 * pi,
                  child: IconButton(
                      icon: const Icon(Icons.sort),
                      onPressed: () {
                        setState(() {
                          isReverse = !isReverse;
                        });
                      }),
                ),
                // Checkbox(
                //     activeColor: Colors.green,
                //     checkColor: Colors.white,
                //     value: cubit.isMoshaf,
                //     onChanged: ((value) {
                //       cubit.CeckBoxEdite(value);
                //       // setState(() {
                //       //   value = !isMoshaf;
                //       // });
                //     })),

                // IconButton(
                //   icon: const Icon(Icons.save),
                //   onPressed: () {
                //     int _id = CacheHelper.getData(key: 'idSurah');
                //     // print('get id surah $_id');

                //     if (CacheHelper.getData(key: 'idSurah') != null) {
                //       SettingCubit.get(context).surahList.forEach((element) {
                //         if (element.id == _id) {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute<void>(
                //               builder: (BuildContext context) =>
                //                   SurahPage(surah: element),
                //             ),
                //           );
                //         } else {}
                //       });
                //     }
                //   },
                // ),
              ],
            ),
            floatingActionButton: FutureBuilder(
              future: readAwadiJson(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return FloatingActionButton(
                  tooltip: 'المحفوظ',
                  child: const Icon(Icons.bookmark),
                  backgroundColor: Colors.blue,
                  onPressed: () async {
                    fabIsClicked = true;
                    if (await readBookmark() == true) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SurahBuilder(
                                    arabic: snapshot.data[0],
                                    sura: bookmarkedSura - 1,
                                    suraName: arabicName[bookmarkedSura - 1]
                                        ['name'],
                                    ayah: bookmarkedAyah,
                                  )));
                    }
                  },
                );
              },
            ),
            body: surahList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : chaptersList(
                    isReverse ? surahList.reversed.toList() : surahList),
          );
        });
  }

  Widget chaptersList(List<Surah> chapters) {
    return BlocConsumer<SettingCubit, SettingStates>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        var cubit = SettingCubit.get(context);
        return FutureBuilder(
          future: readAwadiJson(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.hasData) {
                return SuraMethod(chapters, cubit, snapshot.data);
              } else {
                return const Text('Empty data');
              }
            } else {
              return Text('State: ${snapshot.connectionState}');
            }
          },
        );
      },
    );
  }

  Directionality SuraMethod(List<Surah> chapters, SettingCubit cubit, quran) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.separated(
        controller: _controller,
        itemBuilder: (context, index) => ListTile(
          leading: ArabicSuraNumber(
            i: chapters[index].id,
          )
          //  CircleAvatar(
          //   child: Text(chapters[index].id.toString()),
          // ),
          ,
          title: Text(
            chapters[index].name,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(chapters[index].versesCount.toString()),
          trailing: Text(
            chapters[index].arabicName,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                fontFamily: cubit.fontSize > 30 ? quranFont : me_quranFont),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => cubit.isMoshaf
                  ? SurahBuilder(
                      arabic: quran[0],
                      // sura: bookmarkedSura - 1,
                      sura: chapters[index].id - 1,
                      // suraName: arabicName[bookmarkedSura - 1]['name'],
                      suraName: arabicName[chapters[index].id - 1]['name'],
                      ayah: bookmarkedAyah,
                    )
                  : SurahPage(surah: chapters[index]),
            ),
          ),
        ),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemCount: chapters.length,
      ),
    );
  }
}

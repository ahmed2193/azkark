import 'package:azkark/providers/setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../../util/assets_path.dart';
import '../../../../util/conestans.dart';
import '../controller/app_cubit.dart';
import '../controller/app_states.dart';

// class SurahBuilder extends StatefulWidget {
//   final sura;
//   final arabic;
//   final suraName;
//   int ayah;

//   SurahBuilder(
//       {Key? key, this.sura, this.arabic, this.suraName, required this.ayah})
//       : super(key: key);

//   @override
//   _SurahBuilderState createState() => _SurahBuilderState();
// }

class SurahBuilder extends StatelessWidget {
  final sura;
  final arabic;
  final suraName;
  int ayah;

  SurahBuilder({Key key, this.sura, this.arabic, this.suraName, this.ayah})
      : super(key: key);
  // @override
  // void initState() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) => jumbToAyah());
  //   super.initState();
  // }

  // jumbToAyah() {
  //   if (fabIsClicked) {
  //     itemScrollController.scrollTo(
  //         index: ayah,
  //         duration: const Duration(seconds: 2),
  //         curve: Curves.easeInOutCubic);
  //   }
  //   fabIsClicked = false;
  // }

  Widget verseBuilder(int index, previousVerses) {
    return BlocConsumer<SettingCubit, SettingStates>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        var cubit = SettingCubit.get(context);
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    arabic[index + previousVerses]['aya_text'],
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: cubit.fontSize,
                      fontFamily: arabicFont,
                      color: const Color.fromARGB(196, 0, 0, 0),
                    ),
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.stretch,
                  //   children: [],
                  // ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  SafeArea SingleSuraBuilder(LenghtOfSura, view) {
    String fullSura = '';
    int previousVerses = 0;
    if (sura + 1 != 1) {
      for (int i = sura - 1; i >= 0; i--) {
        previousVerses = previousVerses + noOfVerses[i];
      }
    }

    if (!view)
      for (int i = 0; i < LenghtOfSura; i++) {
        fullSura += (arabic[i + previousVerses]['aya_text']);
      }
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: const Color.fromARGB(255, 253, 251, 240),
          child: view
              ? ScrollablePositionedList.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        (index != 0) || (sura == 0) || (sura == 8)
                            ? const Text('')
                            : const ReturnBasmala(),
                        Container(
                          color: index % 2 != 0
                              ? const Color.fromARGB(255, 253, 251, 240)
                              : const Color.fromARGB(255, 253, 247, 230),
                          child: PopupMenuButton(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: verseBuilder(index, previousVerses),
                              ),
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                      onTap: () {
                                        saveBookMark(sura + 1, index);
                                      },
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.bookmark_add,
                                            color: Color.fromARGB(
                                                255, 56, 115, 59),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text('احفظ الايه'),
                                        ],
                                      ),
                                    ),
                                  ]),
                        ),
                      ],
                    );
                  },
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  itemCount: LenghtOfSura,
                )
              : ListView(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              sura + 1 != 1 && sura + 1 != 9
                                  ? const ReturnBasmala()
                                  : const Text(''),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  fullSura, //mushaf mode
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: mushafFontSize,
                                    fontFamily: arabicFont,
                                    color:
                                        const Color.fromARGB(196, 44, 44, 44),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int LengthOfSura = noOfVerses[sura];
    return BlocProvider(
      create: (context) => AppCubit()..initState(ayah),
      child: BlocConsumer<AppCubit, AppStates>(listener: (context, state) {
        // TODO: implement listener
      }, builder: (context, state) {
        var cubit = AppCubit.get(context);
        var view = AppCubit.get(context).view;
        return Scaffold(
          appBar: AppBar(
            // actions: [
            //   IconButton(
            //       onPressed: () {
            //         Navigator.push(context,
            //             MaterialPageRoute(builder: (context) => Settings()));
            //       },
            //       icon: Icon(
            //         Icons.settings,
            //       )),
            // ],
            // leading: Tooltip(
            //   message: 'مشاف',
            //   child: TextButton(
            //     child: const Icon(
            //       Icons.chrome_reader_mode,
            //       color: Colors.white,
            //     ),
            //     onPressed: () {
            //       cubit.ChangeView();

            //       // setState(() {
            //       //   view = !view;
            //       // });
            //     },
            //   ),
            // ),

            centerTitle: true,
            title: Text(
              //
              suraName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: me_quranFont,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ]),
            ),
            backgroundColor: Colors.blue,
          ),
          body: SingleSuraBuilder(LengthOfSura, view),
        );
      }),
    );
  }
}

class ReturnBasmala extends StatelessWidget {
  const ReturnBasmala({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Center(
        child: Text(
          "‏ ‏‏ ‏‏‏‏ ‏‏‏‏‏‏ ‏",
          style: TextStyle(fontFamily: quranFont, fontSize: mushafFontSize),
          textDirection: TextDirection.rtl,
        ),
      ),
    ]);
  }
}

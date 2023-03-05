import 'dart:convert';

import 'package:azkark/models/surah.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingCubit extends Cubit<SettingStates> {
  SettingCubit() : super(SettingInitialState());

  static SettingCubit get(context) => BlocProvider.of(context);

  double fontSize = 18.0;

  changeFontSize(double index) {
    fontSize = index;
    emit(SettingChangeFontSizeState());
  }

  List<Surah> surahList = [];
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/surah.json');
    final data = await json.decode(response);
    for (var item in data["chapters"]) {
      surahList.add(Surah.fromMap(item));
    }
    debugPrint(surahList.length.toString());
    // setState(() {});
  }

  bool isMoshaf = false;
  void CeckBoxEdite(value) {
    value = !isMoshaf;
    emit(CheckBoxState());
  }
}

//*********************************************

abstract class SettingStates {}

class SettingInitialState extends SettingStates {}

class SettingChangeFontSizeState extends SettingStates {}

class SettingSaveSurahState extends SettingStates {}

class CheckBoxState extends SettingStates {}

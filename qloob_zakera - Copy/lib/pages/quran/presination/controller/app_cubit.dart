import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../util/conestans.dart';
import 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);
  bool view = true;
  void ChangeView() {
    view = !view;

    emit(ChangeViewSuraState());
  }

  void initState(ayah) {
    WidgetsBinding.instance.addPostFrameCallback((_) => jumbToAyah(ayah));
    emit(InitState());
  }

  jumbToAyah(ayah) {
    if (fabIsClicked) {
      itemScrollController.scrollTo(
          index: ayah,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOutCubic);
    }
    fabIsClicked = false;

    emit(JumbToState());
  }
}

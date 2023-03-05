import 'dart:async';
import 'dart:developer';

import 'package:azkark/pages/prayerTimings/background_screen.dart';
import 'package:azkark/pages/prayerTimings/foreground_screen.dart';

import 'package:azkark/services/azan_notifications.dart';
import 'package:azkark/services/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';


var firstTime = true;

class PrayTims extends StatefulWidget {
   PrayTims({Key key ,@required this.timer , this.nextPrayer,this.currentPrayer,this.reminderTime,this.handlerError,this.visiblityLoader}) : super(key: key);
     Timer timer;
   Prayerr nextPrayer ;
   Prayerr currentPrayer ;
   String reminderTime ;
  bool visiblityLoader ;
  var handlerError ;


  @override
  State<PrayTims> createState() => _PrayTimsState();
}

class _PrayTimsState extends State<PrayTims> {

  @override
  void initState() {
    super.initState();
    
  }

  var firstUpdate = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            BackGroundWidget(widget.currentPrayer),
            ForeGroundWidget(widget.nextPrayer, widget.reminderTime, widget.currentPrayer),
    
            Visibility(
                visible: widget.visiblityLoader,
                child: Container(
                    color: Colors.white54,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(color: const Color(0xFFE26B26)))),
          ],
        ),
      ),
    );
  }

  // void update() {
  //   setState(() {
  //     firstTime = false;
  //     nextPrayer = getNextPrayer()!;
  //     if (nextPrayer.status == "now") currentPrayer = nextPrayer;
  //     for (var element in prayers) {
  //       if (element.selected) currentPrayer = element;
  //     }
  //     reminderTime = calculateRemindTime(nextPrayer);
  //     print(
  //         "Update now with next prayer${nextPrayer.title} current prayer ${currentPrayer?.title} reminded time $reminderTime");
  //   });
  // }


}

const secondTextStyle = TextStyle(color: Color(0xffE26B26));

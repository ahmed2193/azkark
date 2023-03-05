import 'package:flutter/material.dart';
import 'package:arabic_numbers/arabic_numbers.dart';

class ArabicSuraNumber extends StatelessWidget {
  ArabicSuraNumber({Key key, this.i}) : super(key: key);
  final int i;
  final arabicNumber = ArabicNumbers();
  @override
  Widget build(BuildContext context) {
    return Text(
      // "\uFD3E" + (i + 1).toString().toArabicNumbers + "\uFD3F",
      "\uFD3E${arabicNumber.convert((i).toString())}\uFD3F",
      // "\uFD3E" + "\uFD3F",
      style: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontFamily: 'me_quran',
          fontSize: 20,
          shadows: [
            Shadow(
              offset: Offset(.5, .5),
              blurRadius: 1.0,
              color: Colors.amberAccent,
            ),
          ]),
    );
  }
}

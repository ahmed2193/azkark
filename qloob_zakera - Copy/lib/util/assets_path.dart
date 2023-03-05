const String imageAssetsRoot = "assets/images/";
const String TextAssetsRoot = "assets/text/";
const String me_quranFont = "me_quran";
const String quranFont = "quran";

String quranImage = _getAssetsImagePath('quran.png');
String quranJson = _getAssetsTextPath('hafs_smart_v8.json');

String _getAssetsImagePath(String fileName) {
  return imageAssetsRoot + fileName;
}

String _getAssetsTextPath(String fileName) {
  return TextAssetsRoot + fileName;
}

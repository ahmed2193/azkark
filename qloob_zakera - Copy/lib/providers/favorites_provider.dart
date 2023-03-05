import '../database/database_helper.dart';
import '../models/favorite_model.dart';
import 'package:flutter/foundation.dart';

class FavoritesProvider with ChangeNotifier {
  final Map<String, List<FavoriteModel>> _favorites =
      <String, List<FavoriteModel>>{};
  DatabaseHelper databaseHelper = DatabaseHelper();
  final List<String> _tables = [
    'favorites_categories',
    'favorites_prayer',
    'favorites_tasbih'
  ];

  int length(int tableIndex) => _favorites[_tables[tableIndex]].length;

  bool isEmpty(int tableIndex) => _favorites[_tables[tableIndex]].isEmpty;

  int newId(int tableIndex) {
    return _favorites[_tables[tableIndex]].isEmpty
        ? 0
        : _favorites[_tables[tableIndex]][length(tableIndex) - 1].id + 1;
  }

  int getItemId(int tableIndex, int index) {
    return _favorites[_tables[tableIndex]][index].itemId;
  }

  FavoriteModel getFavorite(int tableIndex, int index) {
    return _favorites[_tables[tableIndex]][index];
  }

  Future<bool> addFavorite(int tableIndex, int itemId) async {
    try {
      await databaseHelper.insert(_tables[tableIndex],
          FavoriteModel(newId(tableIndex), itemId).toMap());
      _favorites[_tables[tableIndex]]
          .add(FavoriteModel(newId(tableIndex), itemId));
      debugPrint('addFavorite');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Faild addFavorite');
      debugPrint('e : $e');
      return false;
    }
  }

  Future<bool> deleteFavorite(int tableIndex, int itemId) async {
    try {
      await databaseHelper.delete(
        table: _tables[tableIndex],
        tableField: 'item_id',
        id: itemId,
      );
      for (int i = 0; i < length(tableIndex); i++) {
        if (_favorites[_tables[tableIndex]][i].itemId == itemId) {
          _favorites[_tables[tableIndex]].removeAt(i);
          break;
        }
      }

      debugPrint('deleteFavorite');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Faild addFavorite');
      debugPrint('e : $e');
      return false;
    }
  }

  Future<bool> initialAllFavorites() async {
    try {
      Map<int, List<Map<String, dynamic>>> tempFavorites =
          <int, List<Map<String, dynamic>>>{};
      for (int i = 0; i < _tables.length; i++) {
        _favorites[_tables[i]] = <FavoriteModel>[];
        tempFavorites[i] = <Map<String, dynamic>>[];
        tempFavorites[i] = await databaseHelper.getData(_tables[i], '-1');

        for (int j = 0; j < tempFavorites[i].length; j++) {
          _favorites[_tables[i]]
              .add(FavoriteModel.fromMap(tempFavorites[i][j]));
        }

        debugPrint(
            '_favorites[${_tables[i]}].length : ${_favorites[_tables[i]].length}');
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Faild initialAllFavorites');
      debugPrint('e : $e');
      return false;
    }
  }
}

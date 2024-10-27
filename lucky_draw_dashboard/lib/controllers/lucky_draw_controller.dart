import 'package:get/get.dart';

import '../models/lucky_draw_model.dart';

class LuckyDrawController extends GetxController {
  var luckyDraws = <LuckyDraw>[].obs;

  void createLuckyDraw(LuckyDraw luckyDraw) {
    luckyDraws.add(luckyDraw);
  }

  void editLuckyDraw(String id, LuckyDraw updatedLuckyDraw) {
    int index = luckyDraws.indexWhere((draw) => draw.id == id);
    if (index != -1) {
      luckyDraws[index] = updatedLuckyDraw;
    }
  }

  void deleteLuckyDraw(String id) {
    luckyDraws.removeWhere((draw) => draw.id == id);
  }
}

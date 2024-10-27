import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/lucky_draw_controller.dart';
import '../models/lucky_draw_model.dart';

class LuckyDrawPage extends StatelessWidget {
  final LuckyDrawController controller = Get.put(LuckyDrawController());

  LuckyDrawPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Lucky Draws"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              var newLuckyDraw =
                  LuckyDraw(id: "1", qrCode: "QR123", prizeName: "Prize 1");
              controller.createLuckyDraw(newLuckyDraw);
            },
            child: const Text("Create Lucky Draw"),
          ),
          Obx(
            () => Expanded(
              child: ListView.builder(
                itemCount: controller.luckyDraws.length,
                itemBuilder: (context, index) {
                  final draw = controller.luckyDraws[index];
                  return ListTile(
                    title: Text(draw.prizeName),
                    subtitle: Text("QR: ${draw.qrCode}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            var updatedLuckyDraw = LuckyDraw(
                                id: draw.id,
                                qrCode: "New QR",
                                prizeName: "Updated Prize");
                            controller.editLuckyDraw(draw.id, updatedLuckyDraw);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            controller.deleteLuckyDraw(draw.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

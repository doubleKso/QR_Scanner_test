class LuckyDraw {
  String id;
  String qrCode;
  String prizeName;
  
  LuckyDraw({required this.id, required this.qrCode, required this.prizeName});

  factory LuckyDraw.fromJson(Map<String, dynamic> json) {
    return LuckyDraw(
      id: json['id'],
      qrCode: json['qr_code'],
      prizeName: json['prize_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qr_code': qrCode,
      'prize_name': prizeName,
    };
  }
}

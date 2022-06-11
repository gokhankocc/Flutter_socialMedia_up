import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum {
  final String id;
  final String icerik;
  final String yayinlayanId;
  final Timestamp olusturulmaZamani;

  Yorum(
      {this.id = '',
      this.icerik = '',
      this.yayinlayanId = '',
      required this.olusturulmaZamani});

  factory Yorum.dokumandanUret(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data()!;
    return Yorum(
      id: doc.id,
      icerik: data.containsKey("icerik") ? data["icerik"] : '',
      yayinlayanId:
          data.containsKey("yayinlayanId") ? data["yayinlayanId"] : '',
      olusturulmaZamani: data.containsKey("olusturulmaZamani")
          ? data["olusturulmaZamani"]
          : '',
    );
  }
}

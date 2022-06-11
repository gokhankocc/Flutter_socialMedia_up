// ignore_for_file: camel_case_types, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmedia/modeller/gonderi.dart';

import '../modeller/kullanici.dart';

class firestoreServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime zaman = DateTime.now();

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl = ""}) async {
    await _firestore.collection("Kullanicilar").doc(id).set({
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": fotoUrl,
      "hakkinda": "",
      "olusturulmaZamani": zaman
    });
  }

  Future<Kullanici?> kullaniciGetir(id) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection("Kullanicilar").doc(id).get();
    if (doc.exists) {
      //doc.exists : eğer böyle bir dokuman varsa demiş olduk
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      //print(doc.get("takipciler"));
      return kullanici;
    }
    return null;
  }

  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection("Kullanicilar")
        .where("kullaniciAdi", isGreaterThanOrEqualTo: kelime)
        .get();

    List<Kullanici> kullanicilar =
        snapshot.docs.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kullanicilar;
  }

  void kullaniciGuncelle(
      {String? kullaniciId,
      String? kullaniciAdi,
      String? fotoUrl = "",
      String? hakkinda}) {
    _firestore.collection("Kullanicilar").doc(kullaniciId).update({
      "kullaniciAdi": kullaniciAdi,
      "hakkinda": hakkinda,
      "fotoUrl": fotoUrl
    });
  }

  void takipEt({String? aktifKullaniciId, String? profilSahibiId}) {
    _firestore
        .collection("Takipciler")
        .doc(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .doc(aktifKullaniciId)
        .set({});

    _firestore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicinintakipleri")
        .doc(profilSahibiId)
        .set({});
  }

  void takiptenCik({String? aktifKullaniciId, String? profilSahibiId}) {
    _firestore
        .collection("Takipciler")
        .doc(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .doc(aktifKullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    _firestore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicinintakipleri")
        .doc(profilSahibiId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> takipkontrol(
      {String? aktifKullaniciId, String? profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicinintakipleri")
        .doc(profilSahibiId)
        .get();
    if (doc.exists) {
      return true;
    }
    return false;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection("Takipciler")
        .doc(kullaniciId)
        .collection("kullanicininTakipcileri")
        .get();

    return snapshot.docs.length;
  }

  /*Future<int> takipciSayisi(kullaniciId) async {//hasan Ali hoca
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection("Takipciler").doc(kullaniciId).get();
    print(snapshot.get("kullanicininTakipcileri"));

    return snapshot.get("kullanicininTakipcileri").length;
  }*/

  Future<int> takipEdilenler(kullaniciId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection("takipedilenler")
        .doc(kullaniciId)
        .collection("kullanicinintakipleri")
        .get();

    return snapshot.docs.length;
  }

  Future<void> gonderiOlustur(
      {gonderiResmiUrl, aciklama, yayinlayanId, konum}) async {
    await _firestore
        .collection("gonderiler")
        .doc(yayinlayanId)
        .collection("kullaniciGonderileri")
        .add({
      "gonderiResmiUrl": gonderiResmiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayanId,
      "begeniSayisi": 0,
      "konum": konum,
      "olusturulmaZamani": zaman
    });
  }

  Future<List<Gonderi>> gonderileriGetir(kullaniciId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection("gonderiler")
        .doc(kullaniciId)
        .collection("kullaniciGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        .get();
    List<Gonderi> gonderiler =
        snapshot.docs.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<void> gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);
    DocumentSnapshot<Map<String, dynamic>> doc = await docRef.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi! + 1;
      docRef.update({"begeniSayisi": yeniBegeniSayisi});

      //Kullanıcı-Gönderi İlişkisini Beğeniler Koleksiyonuna Ekle
      _firestore
          .collection("begeniler")
          .doc(gonderi.id)
          .collection("gonderiBegenileri")
          .doc(aktifKullaniciId)
          .set({});

      //Beğeni haberini gönderi sahibine iletiyoruz
    }
  }

  Future<void> gonderiBegenikaldir(
      Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);
    DocumentSnapshot<Map<String, dynamic>> doc = await docRef.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi! - 1;
      docRef.update({"begeniSayisi": yeniBegeniSayisi});

      //Kullanıcı-Gönderi İlişkisini Beğeniler Koleksiyonundan sil
      DocumentSnapshot<Map<String, dynamic>> docBegeni = await _firestore
          .collection("begeniler")
          .doc(gonderi.id)
          .collection("gonderiBegenileri")
          .doc(aktifKullaniciId)
          .get();

      if (docBegeni.exists) {
        docBegeni.reference.delete();
      }

      //Beğeni haberini gönderi sahibine iletiyoruz
    }
  }

  Future<bool> begeniVarmi(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot<Map<String, dynamic>> docBegeni = await _firestore
        .collection("begeniler")
        .doc(gonderi.id)
        .collection("gonderiBegenileri")
        .doc(aktifKullaniciId)
        .get();

    if (docBegeni.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> yorumlariGetir(String? gonderiId) {
    return _firestore
        .collection("yorumlar")
        .doc(gonderiId)
        .collection("gonderiYorumlari")
        .orderBy("olusturulmaZamani", descending: true)
        .snapshots();
  }

  void yorumEkle({String? aktifKullaniciId, Gonderi? gonderi, String? icerik}) {
    _firestore
        .collection("yorumlar")
        .doc(gonderi!.id)
        .collection("gonderiYorumlari")
        .add({
      "icerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "olusturulmaZamani": zaman,
    });

    //Yorum duyurusunu gönderi sahibine iletiyoruz.
  }
}

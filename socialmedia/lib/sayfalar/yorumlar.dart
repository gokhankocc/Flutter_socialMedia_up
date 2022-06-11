// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_local_variable, prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/modeller/gonderi.dart';
import 'package:socialmedia/modeller/kullanici.dart';
import 'package:socialmedia/modeller/yorum.dart';
import 'package:socialmedia/servisler/firestoreServisi.dart';
import 'package:socialmedia/servisler/yetkilendirmeServisi.dart';
import 'package:timeago/timeago.dart' as timeago;

class Yorumlar extends StatefulWidget {
  final Gonderi gonderi;
  const Yorumlar({Key? key, required this.gonderi}) : super(key: key);

  @override
  State<Yorumlar> createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  TextEditingController _yorumkontrolcusu = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    //yorumların paylaşılma zamanını türkçe göstermek iiçin pub.dev den hazır aldık
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Yorumlar",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black), //otomatik buton rengi
      ),
      body: Column(children: <Widget>[
        _yorumlarigoster(),
        _yorumEkle(),
      ]),
    );
  }

  _yorumlarigoster() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: firestoreServisi().yorumlariGetir(widget.gonderi.id),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                Yorum yorum = Yorum.dokumandanUret(snapshot.data.docs[index]);
                return _yorumSatiri(yorum);
              });
          // ListView.builder: her gönderi için farklı sayida yorumlari gösterebilmek için kullandık.
        },
      ),
    );
  }

  _yorumSatiri(Yorum yorum) {
    return FutureBuilder<Kullanici?>(
        future: firestoreServisi().kullaniciGetir(yorum.yayinlayanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0.0,
            );
          }

          Kullanici? yayinlayan = snapshot.data;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(yayinlayan!.fotoUrl),
            ),
            title: RichText(
              text: TextSpan(
                  text: yayinlayan.kullaniciAdi + " ",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: yorum.icerik,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.normal),
                    )
                  ]),
            ),
            subtitle: Text(
                timeago.format(yorum.olusturulmaZamani.toDate(), locale: "tr")),
          );
        });
  }

  /*_yorumSatiri(Yorum? yorum) {
    return FutureBuilder<Kullanici?>(
        future: firestoreServisi().kullaniciGetir(yorum!.yayinlayanId),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0.0,
            );
          }

          Kullanici? yayinlayan = snapshot.data;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(yayinlayan!.fotoUrl),
            ),
            title: RichText(
                text: TextSpan(
                    text: yayinlayan.kullaniciAdi + " ",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                  TextSpan(
                      text: yorum.icerik,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ))
                ])),
            //subtitle: Text(timeago.format(yorum.olusturulmaZamani.toDate(), locale: "tr")),
          );
        });
  }*/

  _yorumEkle() {
    return ListTile(
      title: TextFormField(
        controller: _yorumkontrolcusu,
        decoration: InputDecoration(hintText: "yorumları buraya yaz"),
      ),
      trailing: IconButton(icon: Icon(Icons.send), onPressed: _yorumGonder),
    );
  }

  void _yorumGonder() {
    String? aktifkullaniciid =
        Provider.of<yetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    firestoreServisi().yorumEkle(
        aktifKullaniciId: aktifkullaniciid,
        gonderi: widget.gonderi,
        icerik: _yorumkontrolcusu.text);
    _yorumkontrolcusu.clear();
  }
}

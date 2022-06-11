// ignore_for_file: prefer_const_constructors, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:socialmedia/modeller/kullanici.dart';
import 'package:socialmedia/sayfalar/profil.dart';
import 'package:socialmedia/servisler/firestoreServisi.dart';

class Ara extends StatefulWidget {
  const Ara({Key? key}) : super(key: key);

  @override
  State<Ara> createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _aramaController = TextEditingController();

  Future<List<Kullanici>>? _aramasonucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramasonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBarOlustur() {
    return AppBar(
      backgroundColor: Colors.grey[100],
      title: TextFormField(
        onFieldSubmitted: (girilendeger) {
          //onFieldSubmitted : text alanına girilen degeri onayladıgımızda bu metod çalışır
          setState(() {
            _aramasonucu = firestoreServisi().kullaniciAra(girilendeger);
          });
        },
        controller: _aramaController,
        decoration: InputDecoration(
          hintText: "Kullanici Ara",
          border: InputBorder.none, //gölgeyi kaldırdık
          prefixIcon: Icon(
            Icons.search,
            size: 35.0,
          ),
          suffixIcon: IconButton(
              onPressed: () {
                _aramaController.clear();
                setState(() {
                  _aramasonucu = null;
                });
              },
              icon: Icon(Icons.close)),
          fillColor: Colors.white, //text alanının içini beyaz yaptık
        ),
      ),
    );
  }

  aramaYok() {
    return Center(child: Text("Kullanıcı Ara"));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
        future: _aramasonucu,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.length == 0) {
            return Center(child: Text("Bu arama için sonuç bulunamadı!"));
          }

          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Kullanici kullanici = snapshot.data[index];
                return kullaniciSatiri(kullanici);
              });
        });
  }

  kullaniciSatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profil(
                      profilSahibiId: kullanici.id,
                    )));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.fotoUrl),
        ),
        title: Text(kullanici.kullaniciAdi,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
